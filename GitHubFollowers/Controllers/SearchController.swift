//
//  SearchViewController.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 27/01/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit
import Combine

class SearchController: UIViewController {
    
    private lazy var logoImageView = UIImageView()
    private lazy var userNameTextFiled = UITextField(placeholder: "Enter a valid User")
    private lazy var callToActionButton = FGButton(backgroundColor: .systemGray, text: "Get Followers")
    
    private var cancellables = Set<AnyCancellable>()
    private var viewModel = SearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubviews(logoImageView, userNameTextFiled, callToActionButton)
        view.backgroundColor = .systemBackground
        configureLogiImageView()
        configureUserNameTextFiled()
        configureCallToActionButton()
        createDissmissTapRecognizer()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    fileprivate func bindViewModel() {
        viewModel.isValidUserName
            .sink { isEnabled in
                self.callToActionButton.isEnabled = isEnabled
                self.callToActionButton.backgroundColor = isEnabled  ? .systemGreen : .systemGray
        }
        .store(in: &cancellables)
    }
}

extension SearchController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        pushFolowerListVc()
        return true
    }
    
    @objc func textDidChange(sender : UITextField){
        guard let text = sender.text else { return }
        self.viewModel.userName = text
    }
}

extension SearchController {
    func createDissmissTapRecognizer(){
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func pushFolowerListVc() {
        self.userNameTextFiled.resignFirstResponder()
        let foloowerListVC = FollowerListController(username: self.viewModel.userName)
        
        
        self.navigationController?.pushViewController(foloowerListVC, animated: true)
        self.userNameTextFiled.resignFirstResponder()
    }
}

extension SearchController {
    
    private func configureCallToActionButton() {
        callToActionButton.addTarget(self, action: #selector(pushFolowerListVc), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            callToActionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            callToActionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            callToActionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            callToActionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureLogiImageView() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.image = Images.ghLogo
        
        let logoImageViewTopConstraintConstant: CGFloat = DeviceTypes.isiPhoneSE || DeviceTypes.isiPhone8Zoomed ? 20 : 80
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: logoImageViewTopConstraintConstant),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 200),
            logoImageView.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func configureUserNameTextFiled() {
        userNameTextFiled.translatesAutoresizingMaskIntoConstraints = false
        userNameTextFiled.delegate = self
        userNameTextFiled.accessibilityIdentifier = "userNameTextFiled"
        userNameTextFiled.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        NSLayoutConstraint.activate([
            userNameTextFiled.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 50),
            userNameTextFiled.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            userNameTextFiled.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            userNameTextFiled.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
