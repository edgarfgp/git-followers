//
//  FGTabBarController.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 06/02/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import Foundation
import UIKit


class FGTabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().tintColor = .systemGreen
        viewControllers = [createSearchViewController() , createFavouriteViewController()]
    }
    
    func createSearchViewController () -> UINavigationController {
        let searchVC = SearchVC()
        searchVC.title = "Search"
        searchVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search , tag: 0)
        
        return UINavigationController(rootViewController: searchVC)
    }
    
    func createFavouriteViewController () -> UINavigationController {
        let favouriteVC = FavouriteListVC()
        favouriteVC.title = "Favourites"
        favouriteVC.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites , tag: 1)
        
        return UINavigationController(rootViewController: favouriteVC)
    }
    
    func creteTabBar() -> UITabBarController {
        let tabBar = UITabBarController()
        UITabBar.appearance().tintColor = .systemGreen
        
        return tabBar
    }
}
