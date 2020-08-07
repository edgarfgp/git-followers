//
//  FGFollowersItemInfoVc.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 01/02/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit

class FGFollowersItemInfoVC: ItemInfoVC {
    
    var didtapFollowers: ((User) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureItems()
    }
    
    private func configureItems() {
        guard let user = user else { return }
        itemInfoViewOne.set(itemInfoType: .followers, withCount: user.followers)
        itemInfoViewTwo.set(itemInfoType: .following, withCount: user.following)
        actionButton.set(backgroundColor: .systemGreen, title: "Get followers")
    }
    
    override func actionButtonTapped() {
        guard let user = user else { return }
        didtapFollowers?(user)
    }
}
