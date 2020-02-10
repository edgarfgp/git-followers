//
//  FavoriteListViewController.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 27/01/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit

class FavoriteListController: UIViewController {
    
    let tableView = UITableView()
    
    var favorites : [Follower] = []
    
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
        
        PersistenceService.retrieveFavorites { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case.success(let favorites):
                if favorites.isEmpty {
                    self.showEmptySatteView(with: "No favorites", in: self.view)
                    self.tableView.bringSubviewToFront(self.view)
                }
                
                self.favorites = favorites
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.view.bringSubviewToFront(self.tableView)
                }
                
            case.failure(let error):
                self.presentFGAlertOnMainThread(title: "Something went wrong", message: error.rawValue, buttonTilte: "Ok")
            }
        }
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
        let destinationVC = FollowerListController(userName: favorite.login)
        
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard editingStyle == .delete else {
            return
        }
        
        PersistenceService.update(favorite: favorites[indexPath.row], actionType: .removing) { [weak self]error in
            
            guard let self = self else { return }
            
            guard let error = error else  {
                
                self.favorites.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                return
            }
            
            self.presentFGAlertOnMainThread(title: "Unable to remove", message: error.rawValue, buttonTilte: "Ok")
        }
    }
}
