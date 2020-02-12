//
//  FGItemInfoVC.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 01/02/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit


class FGReposItemInfoVC: ItemInfoVC {
    
    var didTapGitProfile: ((User) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureItems()
    }
    
    private func configureItems() {
        if let user = user {
            
            itemInfoViewOne.set(itemInfoType: .repo, withCount: user.publicRepos)
            itemInfoViewTwo.set(itemInfoType: .gists, withCount: user.publicGists)
            actionButton.set(backgroundColor: .systemPurple, title: "Github Profile")
        }
    }
    
    override func actionButtonTapped() {
        if let user = user {
             didTapGitProfile?(user)
        }
    }
}
