//
//  UserInfoVCViewController.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 01/02/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit
import Combine
class UserInfoController: UIViewController {
    
    private let padding : CGFloat = 20
    
    private let scrollView = UIScrollView()
    private let contextView = UIView()
    private let headerView = UIView()
    private let itemViewOne = UIView()
    private let itemViewTwo = UIView()
    private let datelabel = FGBodyLabel()
    var viewModel = UserInfoViewModel(gitHubService: GitHubService())
    private var cancelables = Set<AnyCancellable>()
    
    lazy var username : String = {
        return ""
    }()
    
    var didRequestFollowers: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureScrollView()
        layoutUI()
        getUserInfo()
    }
    
    private func configureScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contextView)
        scrollView.pinToEdges(of: view)
        contextView.pinToEdges(of: scrollView)
        
        NSLayoutConstraint.activate([
            contextView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    private func getUserInfo() {
        viewModel.fetchUserInfoData(username: username)
        viewModel.$user
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { user in
                guard let result = user else { return }
                self.configureElements(with: result)
            }) .store(in: &cancelables)
        
    }
    
    private func configureElements(with user: User){
        
        self.add(childVC: FGUserInfoHeaderVC(user: user, gitHubService: GitHubService()), to: self.headerView)
        
        let reposItemsController = FGReposItemInfoVC(user: user)
        
        reposItemsController.didTapGitProfile = { [weak self] user in
            guard let self = self else { return }
            guard let url = URL(string: user.htmlUrl) else {
                self.presentFGAlertOnMainThread(title: "Invalid URL", message: "The usrl attached to this user is invalid ", buttonTilte: "OK")
                return
            }
            
            self.presentSafariVC(with: url)
        }
        
        let followersItemInfoController = FGFollowersItemInfoVC(user: user)
        
        followersItemInfoController.didtapFollowers = { [weak self] user in
            guard let self = self else { return }
            
            guard user.followers != 0 else {
                self.presentFGAlertOnMainThread(title: "No folowers", message: "This user does not have followers.", buttonTilte: "OK")
                return
            }
            
            self.didRequestFollowers?(user.login)
            
            self.dismissVC()
            
        }
        
        self.add(childVC: reposItemsController, to: self.itemViewOne)
        self.add(childVC: followersItemInfoController, to: self.itemViewTwo)
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
            datelabel.heightAnchor.constraint(equalToConstant: 50),
            datelabel.bottomAnchor.constraint(equalTo: contextView.bottomAnchor)
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
