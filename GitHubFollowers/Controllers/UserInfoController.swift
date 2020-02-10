//
//  UserInfoVCViewController.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 01/02/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit

class UserInfoController: UIViewController {
    
    private let padding : CGFloat = 20
    
    private let scrollView = UIScrollView()
    private let contextView = UIView()
    private let headerView = UIView()
    private let itemViewOne = UIView()
    private let itemViewTwo = UIView()
    private let datelabel = FGBodyLabel()
    
    private var username: String
    weak var followrLstDelegate : FollowerListVCdelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureScrollView()
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
    
    private func configureScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contextView)
        scrollView.pinToEdges(of: view)
        contextView.pinToEdges(of: scrollView)
        
        NSLayoutConstraint.activate([
            contextView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contextView.heightAnchor.constraint(equalToConstant: 600)
        ])
    
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    private func getUserInfo() {
        GitHubService.shared.getUserInfo(for: username) { [weak self] result in
            
            guard let self = self else { return }
            switch result {
            case .success(let user) :
                DispatchQueue.main.async { self.configureElements(with: user) }
            case .failure(let error) :
                self.presentFGAlertOnMainThread(title: "Error trying to get Userinfo", message: error.rawValue, buttonTilte: "Ok")
            }
        }
    }
    
    private func configureElements(with user: User){
        
        self.add(childVC: FGUserInfoHeaderVC(user: user), to: self.headerView)
        self.add(childVC: FGReposItemInfoVC(user: user, delegate: self), to: self.itemViewOne)
        self.add(childVC: FGFollowersItemInfoVC(user: user, delegate: self), to: self.itemViewTwo)
        self.datelabel.text = "Github Since \(user.createdAt.convertToMonthYearFormat())"
    }
    
    private func layoutUI(){
        
        contextView.addSubviews(headerView, itemViewOne, itemViewTwo, datelabel)
        
        NSLayoutConstraint.activate([
            
            headerView.topAnchor.constraint(equalTo: contextView.safeAreaLayoutGuide.topAnchor, constant: padding),
            headerView.leadingAnchor.constraint(equalTo: contextView.leadingAnchor, constant: padding),
            headerView.trailingAnchor.constraint(equalTo: contextView.trailingAnchor, constant: -padding),
            headerView.heightAnchor.constraint(equalToConstant: 210),
            
            itemViewOne.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: padding),
            itemViewOne.leadingAnchor.constraint(equalTo: contextView.leadingAnchor, constant: padding),
            itemViewOne.trailingAnchor.constraint(equalTo: contextView.trailingAnchor, constant: -padding),
            itemViewOne.heightAnchor.constraint(equalToConstant: 140),
            
            itemViewTwo.topAnchor.constraint(equalTo: itemViewOne.bottomAnchor, constant: padding),
            itemViewTwo.leadingAnchor.constraint(equalTo: contextView.leadingAnchor, constant: padding),
            itemViewTwo.trailingAnchor.constraint(equalTo: contextView.trailingAnchor, constant: -padding),
            itemViewTwo.heightAnchor.constraint(equalToConstant: 140),
            
            datelabel.topAnchor.constraint(equalTo: itemViewTwo.bottomAnchor, constant: padding),
            datelabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            datelabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func add(childVC: UIViewController, to containerView: UIView) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
    }
    
    @objc func dismissVC(){
        dismiss(animated: true)
    }
}

extension UserInfoController : FGReposItemInfoVcDelgate {
    func didTapGitProfile(for user: User) {
        
        guard let url = URL(string: user.htmlUrl) else {
            presentFGAlertOnMainThread(title: "Invalid URL", message: "The usrl attached to this user is invalid ", buttonTilte: "OK")
            return
        }
        
        presentSafariVC(with: url)
    }
}

extension UserInfoController : FGFollowersItemInfoVcDelgate {
    func didtapFollowers(for user: User) {
        
        guard user.followers != 0 else {
            presentFGAlertOnMainThread(title: "No folowers", message: "This user does not have followers.", buttonTilte: "OK")
            return
        }
        
        followrLstDelegate.didRequestFollowers(username: user.login)
        
        dismissVC()
    }
}
