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
    
    
    private let notificationCenter = NotificationCenter.default
    private lazy var logoImageView = UIImageView()
    private lazy var userNameTextFiled = UITextField(placeholder: "Enter a valid User")
    private lazy var callToActionButton = FGButton(backgroundColor: .systemGray, text: "Get Followers")
    
    private var viewModel = SearchViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubviews(logoImageView, userNameTextFiled, callToActionButton)
        view.backgroundColor = .systemBackground
        configureLogiImageView()
        configureUserNameTextFiled()
        configureCallToActionButton()
        createDissmissTapRecognizer()
        observesTextField()
    }
    
    private func observesTextField() {
        notificationCenter.publisher(for: UITextField.textDidChangeNotification, object: userNameTextFiled)
            .sink(receiveValue: { [weak self]value in
                    guard let self = self else { return }
                    guard let tetxField = value.object as? UITextField else { return }
                    guard let text = tetxField.text else { return }
                
                DispatchQueue.main.async {
                    self.callToActionButton.isEnabled = !text.isEmpty
                    self.callToActionButton.backgroundColor =  !text.isEmpty ? .systemGreen : .systemGray
                }
            }).store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        userNameTextFiled.text = ""
        callToActionButton.isEnabled = false
        callToActionButton.backgroundColor = .systemGray
    }
    
    func createDissmissTapRecognizer(){
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func pushFolowerListVc() {
        guard let userName = self.userNameTextFiled.text else { return }

        viewModel.validateUserName(for: userName) { status, message in
            if status {
                self.userNameTextFiled.resignFirstResponder()
                let foloowerListVC = FollowerListController()
                foloowerListVC.userName = userName
                self.navigationController?.pushViewController(foloowerListVC, animated: true)
                self.userNameTextFiled.resignFirstResponder()
                
            }else{
                self.presentFGAlertOnMainThread(
                title: "Empty Username",
                message: message,
                buttonTilte: "Ok")
            }
        }
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
                        
        NSLayoutConstraint.activate([
            userNameTextFiled.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 50),
            userNameTextFiled.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            userNameTextFiled.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            userNameTextFiled.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureCallToActionButton() {
        callToActionButton.addTarget(self, action: #selector(pushFolowerListVc), for: .touchUpInside)
        callToActionButton.isEnabled = false

        NSLayoutConstraint.activate([
            callToActionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            callToActionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            callToActionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            callToActionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

extension SearchController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        pushFolowerListVc()
        return true
    }
    
}
