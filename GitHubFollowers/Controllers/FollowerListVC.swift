//
//  FollowerListViewController.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 27/01/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit

class FollowerListVC: UIViewController {
    
    var userName : String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        NetworkManager.shared.getFollowers(for: userName, page: 1) { (followers, errorMesage) in
            guard let followers = followers else {
                self.presentFGAlertOnMainThread(title: "Bad stuff happened", message: errorMesage!.rawValue, buttonTilte: "Ok")
                return
            }
            
            print("Followers count : \(followers.count)")
            print(followers)
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

}
