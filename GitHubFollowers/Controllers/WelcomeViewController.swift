//
//  WelcomeViewController.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez on 29/09/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    private lazy var logoImageView = UIImageView()
    private var gitHubActionButton = FGButton(backgroundColor: .green, text: "GitHub")
    private var anonymusActionButton = FGButton(backgroundColor: .gray, text: "Anonymus")
    
    private var viewModel : WelcomeViewModel = WelcomeViewModel(githubService: GitHubService())
    
    let containerView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        
        self.gitHubActionButton.translatesAutoresizingMaskIntoConstraints = false
        self.anonymusActionButton.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.image = Images.ghLogo
        logoImageView.contentMode = .scaleToFill
        
        containerView.axis = .vertical
        containerView.spacing = 24
        containerView.backgroundColor = .clear
        
        containerView.addArrangedSubview(logoImageView)
        containerView.addArrangedSubview(gitHubActionButton)
        containerView.addArrangedSubview(anonymusActionButton)
        
        self.view.addSubview(containerView)
        
        containerView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16).isActive = true
        containerView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        gitHubActionButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        anonymusActionButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        logoImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        gitHubActionButton.addTarget(self, action: #selector(performAuthentication), for: .touchUpInside)
    }
    
    @objc private func performAuthentication(){
        viewModel.authenticateWithGitHub()
    }

}
