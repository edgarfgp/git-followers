//
//  FollowerListViewModel.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez on 08/08/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import Foundation

class FollowerListViewModel {
    
    var gitHubService : GitHubService
    var persistenceService : PersistenceService
    
    typealias FetchFollowerInfoCallback = (_ follower : Follower?, _ error : FGError?) -> Void
    typealias FetchFollowersCallback = (_ follower : [Follower]?, _ error : FGError?) -> Void
    typealias UpdatePersistenceServiceCallback = (_ error : FGError?) -> Void
    
    var fetchFollowerInfoCallback : FetchFollowerInfoCallback?
    var fetchFollowersCallback : FetchFollowersCallback?
    var updatePersistenceServiceCallback : UpdatePersistenceServiceCallback?
    
    init(gitHubService : GitHubService, persistenceService : PersistenceService) {
        self.gitHubService = gitHubService
        self.persistenceService = persistenceService
    }
    
    func fetchUserFollowers(username: String, page: Int){
        gitHubService.getFollowers(for: username, page: page) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let followers) :
                self.fetchFollowersCallback?(followers, nil)
                
            case .failure(let error) :
                self.fetchFollowersCallback?(nil, error)
            }
        }
    }
    
    func fetchFollowerInfo(userName: String) {
        gitHubService.getUserInfo(for: userName) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                let follower = Follower(login: user.login, avatarUrl: user.avatarUrl)
                self.updatePersistenceService(follower: follower)
            case .failure(let error):
                self.fetchFollowerInfoCallback?(nil, error)
            }
        }
    }
    
    private func updatePersistenceService(follower: Follower){
        self.persistenceService.update(favorite: follower, actionType: PersistenceActionType.adding) { [weak self] error in
            guard let self = self else { return }
            guard let error = error else {
                self.fetchFollowerInfoCallback?(follower, nil)
                return
            }
            self.fetchFollowerInfoCallback?(nil, error)
        }
    }
}
