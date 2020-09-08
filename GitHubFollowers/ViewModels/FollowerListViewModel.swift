//
//  FollowerListViewModel.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez on 08/08/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import Foundation
import Combine

class FollowerListViewModel : ObservableObject {
    
    lazy var filteredFolowers : [Follower] = []
    lazy var followers: [Follower] = []
    lazy var userName : String = ""
    lazy var page : Int = 1
    lazy var isSearching = false
    
    var cancellables = Set<AnyCancellable>()
    
    var gitHubService : GitHubService
    var persistenceService : PersistenceService
    
    private var followersSubject = PassthroughSubject<[Follower], FGError>()
    private var fiteredFollowersSubject = PassthroughSubject<[Follower], Never>()
    private var followerSubject = PassthroughSubject<Follower, FGError>()
    
    var followersPublisher : AnyPublisher<[Follower], FGError> {
        return followersSubject.eraseToAnyPublisher()
    }
    
    var fiteredFollowersPublisher : AnyPublisher<[Follower], Never> {
        return fiteredFollowersSubject.eraseToAnyPublisher()
    }
    
    var followerPublisher : AnyPublisher<Follower, FGError> {
        return followerSubject.eraseToAnyPublisher()
    }
    
    init(gitHubService : GitHubService, persistenceService : PersistenceService) {
        self.gitHubService = gitHubService
        self.persistenceService = persistenceService
    }
    
    func fetchUserFollowers(userName : String, page: Int){
        self.userName = userName
        self.gitHubService.fetchFollowers(userName: userName, page: page) { [weak self] result in
            switch result {
            case .success(let followers) :
                self?.followersSubject.send(followers)
                self?.followers.append(contentsOf: followers)
                
            case .failure(let error) :
                self?.followersSubject.send(completion: .failure(error))
            }
        }
    }
    
    func fetchFollowerInfo(userName: String) {
        self.gitHubService.fetchUserInfo(urlString: userName) { [weak self] userInfo in
            switch userInfo {
            case .success(let user) :
                let follower = Follower(login: user.login, avatarUrl: user.avatarUrl)
                self?.updatePersistenceService(follower: follower)
                
            case .failure(let error) :
                self?.followerSubject.send(completion: .failure(error))
            }
        }
    }
    
    func filterFollowers(for filter: String){
        filteredFolowers = followers.filter { $0.login.lowercased().contains(filter.lowercased()) }
        fiteredFollowersSubject.send(filteredFolowers)
    }
    private func updatePersistenceService(follower: Follower){
        self.persistenceService.update(favorite: follower, actionType: PersistenceActionType.adding) { [weak self] error in
            guard let self = self else { return }
            guard let error = error else {
                self.followerSubject.send(follower)
                return
            }
            self.followerSubject.send(completion: .failure(error))
        }
    }
}
