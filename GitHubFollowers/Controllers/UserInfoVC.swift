//
//  UserInfoVCViewController.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 01/02/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit

protocol UserInfoVCDelgate : class  {
    func didTapGitProfile(for user: User)
    func didtapFollowers(for user: User)
}

class UserInfoVC: UIViewController {
    
    private var username: String
    
    weak var followrLstDelegate : FollowerListVCdelegate!
    
    private lazy var headerView = UIView()
    private lazy var itemViewOne = UIView()
    private lazy var itemViewTwo = UIView()
    private lazy var datelabel = FGBodyLabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        layoutUI()
        getUserInfo()
    }
    
    init(for userName: String){
        self.username = userName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UserInfoVC : UserInfoVCDelgate {
    
    func didTapGitProfile(for user: User) {
        
        guard let url = URL(string: user.htmlUrl) else {
            presentFGAlertOnMainThread(title: "Invalid URL", message: "The usrl attached to this user is invalid ", buttonTilte: "OK")
            return
        }
        
        presentSafariVC(with: url)
    }
    
    func didtapFollowers(for user: User) {
        
        guard user.followers != 0 else {
            presentFGAlertOnMainThread(title: "No folowers", message: "This user does not have followers.", buttonTilte: "OK")
            return
        }
        
        followrLstDelegate?.didRequestFollowers(username: user.login)
        
        dismissVC()
    }
}

extension UserInfoVC {
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    private func layoutUI(){
        
        view.addSubviews(headerView, itemViewOne, itemViewTwo, datelabel)
        
        let padding : CGFloat = 20
        
        NSLayoutConstraint.activate([
            
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            headerView.heightAnchor.constraint(equalToConstant: 180),
            
            itemViewOne.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: padding),
            itemViewOne.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            itemViewOne.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            itemViewOne.heightAnchor.constraint(equalToConstant: 140),
            
            itemViewTwo.topAnchor.constraint(equalTo: itemViewOne.bottomAnchor, constant: padding),
            itemViewTwo.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            itemViewTwo.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            itemViewTwo.heightAnchor.constraint(equalToConstant: 140),
            
            datelabel.topAnchor.constraint(equalTo: itemViewTwo.bottomAnchor, constant: padding),
            datelabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            datelabel.heightAnchor.constraint(equalToConstant: 18)
            
        ])
    }
    
    func add(childVC: UIViewController, to containerView: UIView) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
    }
    
    private func getUserInfo() {
        NetworkManager.shared.getUserInfo(for: username) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user) :
                DispatchQueue.main.async { self.configureElements(with: user, delegate: self) }
            case .failure(let error) :
                self.presentFGAlertOnMainThread(title: "Error trying to get Userinfo", message: error.rawValue, buttonTilte: "Ok")
            }
        }
    }
    
    private func configureElements(with user: User, delegate: UserInfoVCDelgate){
        
        self.add(childVC: FGUserInfoHeaderVC(user: user), to: self.headerView)
        self.add(childVC: FGReposItemInfoVc(user: user, delegate: self), to: self.itemViewOne)
        self.add(childVC: FGFollowersItemInfoVc(user: user, delegate: self), to: self.itemViewTwo)
        self.datelabel.text = "Github Since \(user.createdAt.convertToMonthYearFormat())"
    }
    
    @objc func dismissVC(){
        dismiss(animated: true)
    }
}
