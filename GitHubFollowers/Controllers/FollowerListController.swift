//
//  FollowerListViewController.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 27/01/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit

enum Section { case main }

class FollowerListController: UICollectionViewController {
    
    private lazy var page : Int = 1
    private lazy var hasMoreFollowers = true
    private lazy var isSearching = false
    private lazy var isLoadingMoreFollowers = false
    lazy var userName : String = ""
        
    private var viewModel = FollowerListViewModel(gitHubService: GitHubService.shared, persistenceService: PersistenceService.shared)
    
    private lazy var dataSource : UICollectionViewDiffableDataSource<Section, Follower> = {
        
        let dataSource = UICollectionViewDiffableDataSource<Section, Follower>(collectionView: collectionView, cellProvider: {
            (collectionView, indexPath, follower) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowerCell.reuseID, for: indexPath) as! FollowerCell
            cell.setFollower(follower: follower)
            return cell
        })
        
        return dataSource
    }()
    
    init() {
        super.init(collectionViewLayout : UICollectionViewFlowLayout())
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = userName
        
        configureViewController()
        configureCollectionView()
        getFollowers(userName: userName, page: page)
        configureSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            guard hasMoreFollowers, !isLoadingMoreFollowers else { return }
            page += 1
            getFollowers(userName: userName, page: page)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activeArray = isSearching ? self.viewModel.filteredFolowers : self.viewModel.followers
        let follower = activeArray[indexPath.item]
        
        let destinationController = UserInfoController()
        destinationController.username = follower.login
        
        destinationController.didRequestFollowers = { [weak self] name in

            guard let self = self else { return }

            self.userName = name
            self.title = self.userName
            self.page = 1
            self.viewModel.followers.removeAll()
            self.viewModel.filteredFolowers.removeAll()
            self.collectionView.setContentOffset(.zero, animated: true)
            self.getFollowers(userName: self.userName, page: self.page)

        }
        
        let navControler = UINavigationController(rootViewController: destinationController)
        present(navControler, animated: true)
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UiHelper.createThreeColumnFlowLayout(in: view) )
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: FollowerCell.reuseID)
    }
    
    private func updateData(on followers: [Follower]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Follower>()
        snapshot.appendSections([.main])
        snapshot.appendItems(followers)
        
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFavoriteTapped))
    }
    
    @objc private func addFavoriteTapped () {
        
        showLoadingView()
        
        viewModel.fetchFollowerInfoCallback = {  [weak self] (follower, error) in
            guard let self = self else { return }
            self.dissmissLoadingView()
            
            guard let error = error else {
                guard let follower = follower else { return }
                self.presentFGAlertOnMainThread(title: "Success", message: "You have added \(follower.login) as favorite 🎉", buttonTilte: "Ok")
                return
                
            }
            self.presentFGAlertOnMainThread(title: "Something went wrong", message: error.rawValue, buttonTilte: "Ok")
        }
        
        viewModel.fetchFollowerInfo(userName: userName)
        
    }
    
    private func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search for a username"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    private func getFollowers(userName: String , page: Int){
        
        showLoadingView()
        
        isLoadingMoreFollowers = true
        
        viewModel.fetchFollowersCallback = { [weak self](followers, error) in
            guard let self = self else { return }
            
            self.dissmissLoadingView()
            
            guard let error = error else {
                guard let followers = followers else { return }
                if followers.count > 100 { self.hasMoreFollowers = false }
                
                if followers.isEmpty {
                    let message = "This users does not have follower 🥺. Go follow them 😀"
                        DispatchQueue.main.async {
                            self.showEmptySatteView(with: message, in: self.view)
                            return
                        }
                }
                
                self.updateData(on: followers)
                
                self.isLoadingMoreFollowers = false
    
                return
            }
            
            self.presentFGAlertOnMainThread(title: "Bad stuff happened", message: error.rawValue, buttonTilte: "Ok")
            
            self.isLoadingMoreFollowers = false
        }
        
        viewModel.fetchUserFollowers(username: userName, page: page)
    }
}

extension FollowerListController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter  = searchController.searchBar.text, !filter.isEmpty else {
            self.viewModel.filteredFolowers.removeAll()
            updateData(on: self.viewModel.followers)
            isSearching = false
            return
        }
        
        isSearching = true
                
        self.viewModel.filterFollowersCallBack = { [weak self] newFollowers in
            guard let self = self else { return }
            self.updateData(on: newFollowers)
        }
        
        self.viewModel.filterFollowers(for: filter)
    }
}