//
//  SearchViewController.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 27/01/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit

class SearchVC: UIViewController {
    
    private lazy var logoImageView = UIImageView()
    
    private lazy var userNameTextFiled = FGTextField()
    
    private lazy var callToActionButton = FGButton(backgroundColor: .systemGreen, text: "Get Followers")
    
    private var isUserNameEntered : Bool { return !userNameTextFiled.text!.isEmpty }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        configureLogiImageView()
        configureUserNameTextFiled()
        configureCallToActionButton()
        createDissmissTapRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

extension SearchVC {
    
    func createDissmissTapRecognizer() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func pushFolowerListVc() {
        
        guard isUserNameEntered  else {
            presentFGAlertOnMainThread(
                title: "Empty Username",
                message: "Please enter a username . We need to know who to look for 😀",
                buttonTilte: "Ok")
            
            return
            
        }
        
        let userNameText = userNameTextFiled.text ?? ""
        
        let foloowerListVC = FollowerListVC(userName: userNameText)
        foloowerListVC.title = userNameTextFiled.text
        navigationController?.pushViewController(foloowerListVC, animated: true)
        userNameTextFiled.resignFirstResponder()
    }
    
    private func configureLogiImageView()  {
           view.addSubview(logoImageView)
           logoImageView.translatesAutoresizingMaskIntoConstraints = false
           logoImageView.image = UIImage(named: "gh-logo")!
           
           NSLayoutConstraint.activate([
               logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
               logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
               logoImageView.heightAnchor.constraint(equalToConstant: 200),
               logoImageView.widthAnchor.constraint(equalToConstant: 200)
           ])
       }
       
       private func configureUserNameTextFiled()  {
           view.addSubview(userNameTextFiled)
           userNameTextFiled.translatesAutoresizingMaskIntoConstraints = false
           userNameTextFiled.delegate = self
           
           NSLayoutConstraint.activate([
               userNameTextFiled.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 50),
               userNameTextFiled.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
               userNameTextFiled.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
               userNameTextFiled.heightAnchor.constraint(equalToConstant: 50)
           ])
       }
       
       private func configureCallToActionButton()  {
           view.addSubview(callToActionButton)
           callToActionButton.addTarget(self, action: #selector(pushFolowerListVc), for: .touchUpInside)
           
           NSLayoutConstraint.activate([
               callToActionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
               callToActionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
               callToActionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
               callToActionButton.heightAnchor.constraint(equalToConstant: 50)
           ])
       }
}

extension SearchVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        pushFolowerListVc()
        return true
    }
}

