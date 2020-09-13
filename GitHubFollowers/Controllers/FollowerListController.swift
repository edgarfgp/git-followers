//
//  FollowerListViewController.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 27/01/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit
import Combine

enum Section { case main }

class FollowerListController: UICollectionViewController {
    var cancellables = Set<AnyCancellable>()
    var viewModel = FollowerListViewModel(gitHubService: GitHubService(), persistenceService: PersistenceService.shared)
    
    private lazy var dataSource : UICollectionViewDiffableDataSource<Section, Follower> = {
        
        let dataSource = UICollectionViewDiffableDataSource<Section, Follower>(collectionView: collectionView, cellProvider: {
            (collectionView, indexPath, follower) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowerCell.reuseID, for: indexPath) as! FollowerCell
            cell.setFollower(follower: follower, service: GitHubService())
            return cell
        })
        
        return dataSource
    }()
    
    init() {
        super.init(collectionViewLayout : UICollectionViewFlowLayout())
    }
    
    lazy var userName : String = {
        return ""
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = userName
        
        configureViewController()
        configureCollectionView()
        getFollowers(userName: userName ,page: viewModel.page)
        configureSearchController()
    }
}

extension FollowerListController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter  = searchController.searchBar.text, !filter.isEmpty else {
            self.viewModel.filteredFolowers.removeAll()
            updateData(on: self.viewModel.followers)
            self.viewModel.isSearching = false
            return
        }
        
        self.viewModel.isSearching = true
        self.viewModel.filterFollowers(for: filter)
        self.viewModel.fiteredFollowersPublisher
            .sink(receiveValue: { newFollowers in
                self.updateData(on: newFollowers)
            }).store(in: &cancellables)
    }
}


extension FollowerListController {
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            viewModel.page += 1
            getFollowers(userName: userName, page: viewModel.page)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activeArray = self.viewModel.isSearching ? self.viewModel.filteredFolowers : self.viewModel.followers
        let follower = activeArray[indexPath.item]
        
        let destinationController = UserInfoController()
        destinationController.username = follower.login
        
        destinationController.didRequestFollowers = { [weak self] name in
            
            guard let self = self else { return }
            
            self.title = self.userName
            self.userName = name
            self.viewModel.page = self.viewModel.page
            self.viewModel.followers.removeAll()
            self.viewModel.filteredFolowers.removeAll()
            self.collectionView.setContentOffset(.zero, animated: true)
            self.getFollowers(userName: self.userName, page: self.viewModel.page)
            
        }
        
        let navControler = UINavigationController(rootViewController: destinationController)
        present(navControler, animated: true)
    }
}

extension FollowerListController {
    
    private func getFollowers(userName: String ,page: Int){
        showLoadingView()
        viewModel.fetchUserFollowers(userName: userName, page: page)
        
        viewModel.followersPublisher
            .sink(receiveCompletion: { [weak self] resultCompletion in
                guard let self = self else { return }
                switch resultCompletion {
                case .failure(_):
                    self.dissmissLoadingView()
                    self.presentFGAlertOnMainThread(title: "Bad stuff happened", message: "Please try agin Later!", buttonTilte: "Ok")
                case .finished : break
                }})
            { [weak self] followers in
                guard let self = self else { return }
                self.dissmissLoadingView()
                
                if followers.isEmpty, self.viewModel.followers.isEmpty {
                    
                    let message = "This users does not have follower 🥺. Go follow them 😀"
                    DispatchQueue.main.async {
                        self.showEmptySatteView(with: message, in: self.view)
                        return
                    }
                }else{
                    let newFollowers = followers.isEmpty ? self.viewModel.followers : followers
                    
                    self.updateData(on: newFollowers)
                }
                
        }.store(in: &cancellables)
        
    }
    
    @objc private func addFavoriteTapped () {
        viewModel.fetchFollowerInfo(userName: userName)
        viewModel.followerPublisher
            .subscribe(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self]resultCompletion in
                guard let self = self else { return }
                
                switch resultCompletion {
                case .failure(let error):
                    self.presentFGAlertOnMainThread(title: "Something went wrong", message: error.rawValue, buttonTilte: "Ok")
                case .finished : break
                }
            }) { follower in
                self.presentFGAlertOnMainThread(title: "Success", message: "You have added \(follower.login) as favorite 🎉", buttonTilte: "Ok")
        }.store(in: &cancellables)
    }
    
    private func updateData(on followers: [Follower]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Follower>()
        snapshot.appendSections([.main])
        snapshot.appendItems(followers)
        
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
}

extension FollowerListController {
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UiHelper.createThreeColumnFlowLayout(in: view) )
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: FollowerCell.reuseID)
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFavoriteTapped))
    }
    
    private func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search for a username"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
}
