//
//  FavoriteListViewController.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 27/01/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit
import Combine

class FavoriteListController: UIViewController {
    
    private lazy var tableView = UITableView()
        
    var viewModel = FavoriteListViewModel(persistenceService: PersistenceService())
    
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
        viewModel.getFavorites {  [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(_) : break
            case .success(let favorites):
                if  favorites.isEmpty {
                    self.showEmptySatteView(with: "No favorites", in: self.view)
                }else {
                    self.tableView.reloadData()
                    self.view.bringSubviewToFront(self.tableView)
                }
            }
        }
    }
}


extension FavoriteListController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.reuseID) as! FavoriteCell
        let favorite = viewModel.favorites[indexPath.row]
        cell.setFavorite(favorite: favorite, service: GitHubService())
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favorite = viewModel.favorites[indexPath.row]
        let destinationVC = FollowerListController()
        destinationVC.userName = favorite.login
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard editingStyle == .delete else { return }
        
        viewModel.updateFavoriteList(favorite: viewModel.favorites[indexPath.row]) { [weak self] message in
            guard let self = self else { return }
            guard let message = message else {
                self.viewModel.favorites.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .left)
                return
            }
            
            self.presentFGAlertOnMainThread(title: "Unable to remove", message: message, buttonTilte: "Ok")
        }
        
        if viewModel.favorites.isEmpty {
            showEmptySatteView(with: "No favorites", in: self.view)
        }
    }
}
