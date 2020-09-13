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
    lazy var page : Int = 1
    lazy var isSearching = false
    
    var cancellables = Set<AnyCancellable>()
    
    var gitHubService : GitHubService
    var persistenceService : PersistenceService
    
    private var fiteredFollowersSubject = PassthroughSubject<[Follower], Never>()
    private var followerSubject = PassthroughSubject<Follower, FGError>()
    
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
    
    func fetchUserFollowers(userName : String, page: Int, completion: @escaping (Result<[Follower], FGError>) -> Void) {
        self.gitHubService.fetchFollowers(userName: userName, page: page)
            .sink(receiveCompletion: { completionResult in
                switch completionResult {
                case .failure(let error):
                    completion(.failure(error))
                case .finished : break
                }
            }) { result in
                completion(.success(result))
                self.followers.append(contentsOf: result)
        }.store(in: &cancellables)
    }
    
    func saveUserTofavorites(userName: String, completion: @escaping (Result<User, FGError>) -> Void) {
        self.gitHubService.fetchUserInfo(urlString: userName)
            .sink(receiveCompletion: { completionResult in
                switch completionResult {
                case .failure(let error):
                    completion(.failure(error))
                case .finished : break
                }
            }) { user in
                let follower = Follower(login: user.login, avatarUrl: user.avatarUrl)
                self.updatePersistenceService(follower: follower)
                completion(.success(user))
        }.store(in: &cancellables)
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
