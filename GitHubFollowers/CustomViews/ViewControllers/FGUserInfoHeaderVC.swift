//
//  FGUserInfoHeaderVC.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 01/02/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit

class FGUserInfoHeaderVC: UIViewController {

    private lazy var avatarImageView  = FGAvatarImageView(frame: .zero)
    private lazy var userNameLabel = FGTitleLabel(textAligment: .left, fontSize: 34)
    private lazy var namelabel = FGSecondaryTitleLabel(fontSize: 18)
    private lazy var locationImageView = UIImageView()
    private lazy var locationLabel = FGSecondaryTitleLabel(fontSize: 18)
    private lazy var bioLabel = FGBodyLabel(textAligment: .left, numberOfLines: 3)
    
    private let user : User
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        configureUI()
        configureUIElements()
    }
}

extension FGUserInfoHeaderVC {
    
    private func addSubViews() {
        view.addSubviews(avatarImageView, userNameLabel, namelabel, locationImageView, locationLabel, bioLabel)
    }
    
    private func configureUIElements() {
        avatarImageView.downloadImage(from: user.avatarUrl)
        userNameLabel.text = user.login
        namelabel.text = user.name ?? ""
        locationLabel.text = user.location ?? "Unkwown lcoation"
        bioLabel.text = user.bio ?? "No bio available"
        
        locationImageView.image =  SFSymbols.location
        locationImageView.tintColor = .secondaryLabel
    }
    
    private func configureUI() {
        
        let textImageViewPadding : CGFloat = 12
        locationImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            avatarImageView.topAnchor.constraint(equalTo: view.topAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            avatarImageView.heightAnchor.constraint(equalToConstant: 90),
            avatarImageView.widthAnchor.constraint(equalToConstant: 90),
            
            userNameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor),
            userNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: textImageViewPadding),
            userNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            userNameLabel.heightAnchor.constraint(equalToConstant: 38),
            
            namelabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor, constant: 8),
            namelabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: textImageViewPadding),
            namelabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            namelabel.heightAnchor.constraint(equalToConstant: 38),
            
            locationImageView.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
            locationImageView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: textImageViewPadding),
            locationImageView.widthAnchor.constraint(equalToConstant: 20),
            locationImageView.heightAnchor.constraint(equalToConstant: 20),
            
            locationLabel.centerYAnchor.constraint(equalTo: locationImageView.centerYAnchor),
            locationLabel.leadingAnchor.constraint(equalTo: locationImageView.trailingAnchor, constant: 5),
            locationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            locationLabel.heightAnchor.constraint(equalToConstant: 20),
            
            bioLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
            bioLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            bioLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bioLabel.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
}
