
//
//  FavoriteCell.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 05/02/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit
import Combine

class FavoriteCell: UITableViewCell {
    
    static let reuseID = "FavoriteCell"
    private lazy var padding: CGFloat = 12
    
    private lazy var avatarImageView = FGAvatarImageView(frame: .zero)
    private lazy var userNameLabel = FGTitleLabel(textAligment: .left, fontSize: 26)
    private var cancelables = Set<AnyCancellable>()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(avatarImageView, userNameLabel)
        
        accessoryType = .disclosureIndicator
        
        NSLayoutConstraint.activate([
            avatarImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            avatarImageView.heightAnchor.constraint(equalToConstant: 60),
            avatarImageView.widthAnchor.constraint(equalToConstant: 60),
            
            userNameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            userNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 24),
            userNameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding),
            userNameLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func setFavorite(favorite: Follower, service : GitHubService){
        userNameLabel.text = favorite.login
        service.fetchImage(from: favorite.avatarUrl) {[weak self] result in
            self?.avatarImageView.image = result
        }
    }
}
