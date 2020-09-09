//
//  FollowerCell.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 30/01/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit
import Combine

class FollowerCell: UICollectionViewCell {
    
    static let reuseID = "FollowerCell"
    private lazy var padding: CGFloat = 8
    
    private lazy var avatarImageView = FGAvatarImageView(frame: .zero)
    private lazy var userNameLabel = FGTitleLabel(textAligment: .center, fontSize: 16)
    private var cancelables = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(){
        
        addSubviews(avatarImageView, userNameLabel)
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            avatarImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            userNameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
            userNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            userNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            userNameLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func setFollower(follower: Follower, service: GitHubService){
        userNameLabel.text = follower.login
        service.fetchImage(from: follower.avatarUrl) { result in
            switch result {
            case .success(let image) :
                 self.avatarImageView.image = image
            case .failure(_) :
                break
            }
        }
    }
}
