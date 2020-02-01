//
//  UserInfoVCViewController.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 01/02/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit

class UserInfoVC: UIViewController {
    
    private var username: String
    
    init(for userName: String){
        self.username = userName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        
        navigationItem.rightBarButtonItem = doneButton
        
        NetworkManager.shared.getUserInfo(for: username) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let user) :
                print(user)
            
            case .failure(let error) :
                self.presentFGAlertOnMainThread(title: "Error trying to get Userinfo", message: error.rawValue, buttonTilte: "Ok")
            }
        }
    }
    
    @objc func dismissVC(){
        dismiss(animated: true)
    }

}
