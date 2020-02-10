//
//  FGFollowersItemInfoVc.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 01/02/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit

protocol FGFollowersItemInfoVcDelgate : class  {
    
    func didtapFollowers(for user: User)
}

class FGFollowersItemInfoVC: ItemInfoVC {
    
    weak var delegate :  FGFollowersItemInfoVcDelgate!
    
    init(user: User, delegate: FGFollowersItemInfoVcDelgate) {
        self.delegate = delegate
        super.init(user: user)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureItems()
    }
    
    private func configureItems() {
        itemInfoViewOne.set(itemInfoType: .followers, withCount: user.followers)
        itemInfoViewTwo.set(itemInfoType: .following, withCount: user.following)
        actionButton.set(backgroundColor: .systemGreen, title: "Get followers")
    }
    
    override func actionButtonTapped() {
        delegate.didtapFollowers(for: user)
    }
}
