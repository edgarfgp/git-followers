//
//  FollowerListViewController.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 27/01/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit

protocol FollowerListVCdelegate : class {
    func didRequestFollowers(username: String)
}

class FollowerListVC: UIViewController {
    
    private var page : Int = 1
    private var hasMoreFollowers = true
    private var isSearching = false
    private var userName : String
    private var followers: [Follower] = []
    private var filteredFolowers : [Follower] = []
    private var collectionView : UICollectionView!
    private var dataSource : UICollectionViewDiffableDataSource<Section, Follower>!
    
    enum Section { case main }
    
    
    init(userName: String) {
        self.userName = userName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureCollectionView()
        getFollowers(userName: userName, page: page)
        configureDataSource()
        configureSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension FollowerListVC {
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UiHelper.createThreeColumnFlowLayout(in: view) )
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: FollowerCell.reuseID)
    }
    
    private func configureDataSource () {
        dataSource = UICollectionViewDiffableDataSource<Section, Follower>(collectionView: collectionView, cellProvider: {
            (collectionView, indexPath, follower) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowerCell.reuseID, for: indexPath) as! FollowerCell
            cell.set(follower: follower)
            return cell
        })
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
    }
    
    private func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search for a username"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    private func getFollowers(userName: String , page: Int){
        
        showLoadingView()
        
        NetworkManager.shared.getFollowers(for: userName, page: page) { [weak self] result in
            
            guard let self = self else { return }
            self.dissmissLoadingView()
            
            switch result {
            case .success(let followers) :
                if followers.count < 100 { self.hasMoreFollowers = false }
                self.followers.append(contentsOf: followers)
                
                if self.followers.isEmpty {
                    let message = "This users does not have follower 🥺. Go follow them 😀"
                    DispatchQueue.main.async {
                        self.showEmptySatteView(with: message, in: self.view)
                        return
                    }
                }
                
                self.updateData(on: followers)

            case .failure(let error) :
                self.presentFGAlertOnMainThread(title: "Bad stuff happened", message: error.rawValue, buttonTilte: "Ok")
            }
        }
    }
}

extension FollowerListVC : UICollectionViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            guard hasMoreFollowers else { return }
            page += 1
            getFollowers(userName: userName, page: page)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activeArray = isSearching ? filteredFolowers : followers
        let follower = activeArray[indexPath.item]
        
        let destinationVc = UserInfoVC(for: follower.login)
        destinationVc.followrLstDelegate = self
        let navControler = UINavigationController(rootViewController: destinationVc)
        present(navControler, animated: true, completion: nil)
    }
    
}

extension FollowerListVC : UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter  = searchController.searchBar.text, !filter.isEmpty else { return }
        
        isSearching = true
        
        filteredFolowers = followers.filter { $0.login.lowercased().contains(filter.lowercased()) }
        
        updateData(on: filteredFolowers)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        updateData(on: followers)
    }
}

extension FollowerListVC : FollowerListVCdelegate {
    
    func didRequestFollowers(username: String) {
        self.userName = username
        title = userName
        page = 1
        followers.removeAll()
        filteredFolowers.removeAll()
        collectionView.setContentOffset(.zero, animated: true)
        
        getFollowers(userName: userName, page: page)
    }
}
