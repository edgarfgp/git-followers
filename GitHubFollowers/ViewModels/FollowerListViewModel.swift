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
    
    @Published var followers: [Follower] = []
    lazy var page : Int = 1
    lazy var isSearching = false
    
    var cancellables = Set<AnyCancellable>()
    
    private lazy var gitHubService = GitHubService()
    private lazy var persistenceService = PersistenceService()
    
    func fetchUserFollowers(userName : String, page: Int, completion: @escaping (Result<[Follower], FGError>) -> Void) {
        gitHubService.fetchFollowers(userName: userName, page: page)
            .sink(receiveCompletion: { completionResult in
                switch completionResult {
                case .failure(let error):
                    completion(.failure(error))
                case .finished : break
                }
            }) { [weak self] result in
                guard let self = self else { return }
                completion(.success(result))
                self.followers.append(contentsOf: result)
            }.store(in: &cancellables)
    }
    
    func fetchUserInfo(userName : String, completion: @escaping (Result<User, FGError>) -> Void) {
        gitHubService.fetchUserInfo(urlString: userName)
            .sink(receiveCompletion: { completionResult in
                switch completionResult {
                case .failure(let error):
                    completion(.failure(error))
                case .finished : break
                }
            }) { user in
                completion(.success(user))
                
            }.store(in: &cancellables)
    }
    
    func saveUserTofavorites(follower: Follower, completion: @escaping (FGError?) -> Void) {
        persistenceService.update(favorite: follower, actionType: PersistenceActionType.adding) { error in
            completion(error)
        }
    }
    
    func filterFollowers(for filter: String, completion: @escaping ([Follower]) -> Void){
        return $followers
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .map{ $0.filter{ $0.login.lowercased().contains(filter.lowercased()) } }
            .sink { newFollowers in
                completion(newFollowers)
            }.store(in: &cancellables)
    }
}
