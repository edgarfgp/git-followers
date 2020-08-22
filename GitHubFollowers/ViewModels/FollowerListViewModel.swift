//
//  FollowerListViewModel.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez on 08/08/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import Foundation
import Combine

class FollowerListViewModel {
    
    lazy var page : Int = 1
    lazy var isSearching = false
    lazy var followers: [Follower] = []
    lazy var filteredFolowers : [Follower] = []
    
    var gitHubService : GitHubService
    var persistenceService : PersistenceService
    
    typealias FetchFollowerInfoCallback = (_ follower : Follower?, _ error : FGError?) -> Void
    typealias UpdatePersistenceServiceCallback = (_ error : FGError?) -> Void
    typealias FilterFollowersCallBack = (_ filteredFollowers : [Follower]) -> Void
    
    var updatePersistenceServiceCallback : UpdatePersistenceServiceCallback?
    var filterFollowersCallBack : FilterFollowersCallBack?
    
    var followersSubject = PassthroughSubject<[Follower], FGError>()
    var followerSubject = PassthroughSubject<Follower, FGError>()
    
    
    init(gitHubService : GitHubService, persistenceService : PersistenceService) {
        self.gitHubService = gitHubService
        self.persistenceService = persistenceService
    }
    
    func fetchUserFollowers(userName : String, page: Int){
        gitHubService.fetchFollowers(userName: userName, page: page) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let followers):
                self.followersSubject.send(followers)
                self.followers.append(contentsOf: followers)
            case .failure(let error) :
                self.followersSubject.send(completion: .failure(error))
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
                self.followerSubject.send(completion: .failure(error))
            }
        }
    }
    
    func filterFollowers(for filter: String){
        filteredFolowers = followers.filter { $0.login.lowercased().contains(filter.lowercased()) }
        filterFollowersCallBack?(filteredFolowers)

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
