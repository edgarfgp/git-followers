//
//  FavoriteListViewController.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 27/01/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit

class FavoriteListController: UIViewController {
    
    private lazy var tableView = UITableView()
    
    private lazy var favorites : [Follower] = []
    
    var viewModel = FavoriteListViewModel(persistenceService: PersistenceService.shared)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureTableView()
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getFavotites()
    }
    
    private func configureTableView () {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.rowHeight = 80
        tableView.dataSource = self
        tableView.delegate = self
        tableView.removeExcessCell()
        tableView.register(FavoriteCell.self, forCellReuseIdentifier: FavoriteCell.reuseID)
    }
    
    private func getFavotites () {
        
        viewModel.getFavoritesCallback = { [weak self] favorites , error in
            guard let self = self else { return }
            
            guard let error = error else {
                guard let favorites = favorites else { return }
                if favorites.isEmpty {
                    self.showEmptySatteView(with: "No favorites", in: self.view)
                }else{
                    self.favorites = favorites
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.view.bringSubviewToFront(self.tableView)
                    }
                }
                return
            }
            self.presentFGAlertOnMainThread(title: "Something went wrong", message: error.rawValue, buttonTilte: "Ok")
            
        }
        
        viewModel.getFavorites()
    }
}

extension FavoriteListController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.reuseID) as! FavoriteCell
        let favorite = favorites[indexPath.row]
        cell.setFavorite(favorite: favorite)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favorite = favorites[indexPath.row]
        let destinationVC = FollowerListController()
        destinationVC.userName = favorite.login
        
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard editingStyle == .delete else {
            return
        }
        
        viewModel.updateFavoritesCallback = { [weak self] message in
            guard let self = self else { return }
            guard let message = message else {
                self.favorites.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                return
            }
            
            self.presentFGAlertOnMainThread(title: "Unable to remove", message: message, buttonTilte: "Ok")
        }
        
        viewModel.updateFavoriteList(favorite: favorites[indexPath.row])
        
        if favorites.isEmpty {
            self.showEmptySatteView(with: "No favorites", in: self.view)
        }
    }
}
