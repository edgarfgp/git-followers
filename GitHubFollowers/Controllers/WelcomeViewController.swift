//
//  WelcomeViewController.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez on 29/09/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    private let buttonHeight: CGFloat = 50
    private let logoImageHeight: CGFloat = 200
    private let defaultPadding: CGFloat = 16
    
    private lazy var logoImageView = FGAvatarImageView(frame: .zero)
    private lazy var loginActionButton = FGButton(backgroundColor: .systemBlue , text: "Login")
    private lazy var anonymousActionButton = FGButton(backgroundColor: .systemBlue, text: "Anonymous")
    private let containerStackView = UIStackView()

    private var viewModel : WelcomeViewModel = WelcomeViewModel(githubService: GitHubService())
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isHidden = true
        
        configureLogoImageAvatar()
        configureLoginActionButton()
        configureAnonymousActionButton()
        configureContainerStackView()
    }
    
    @objc private func performAuthentication(){
        viewModel.authenticateWithGitHub()
    }
    
    @objc private func performAnonymousAction() {
        let tabVC = FGTabBarViewController()
        tabVC.modalPresentationStyle = .overFullScreen
        present(tabVC, animated: true, completion: nil)
    }
}

extension WelcomeViewController {
    
    private func configureLogoImageAvatar(){
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.addArrangedSubview(logoImageView)

        logoImageView.image = Images.ghLogo
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.heightAnchor.constraint(equalToConstant: logoImageHeight).isActive = true
    }
    
    private func configureLoginActionButton(){
        loginActionButton.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.addArrangedSubview(loginActionButton)
        
        loginActionButton.addTarget(self, action: #selector(performAuthentication), for: .touchUpInside)
        loginActionButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
    }
    
    private func configureAnonymousActionButton(){
        anonymousActionButton.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.addArrangedSubview(anonymousActionButton)
        
        anonymousActionButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        anonymousActionButton.addTarget(self, action: #selector(performAnonymousAction), for: .touchUpInside)
    }
    
    private func configureContainerStackView(){
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerStackView)

        
        containerStackView.axis = .vertical
        containerStackView.spacing = 24
        containerStackView.backgroundColor = .clear
        containerStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: defaultPadding).isActive = true
        containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -defaultPadding).isActive = true
        containerStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
    }
}
