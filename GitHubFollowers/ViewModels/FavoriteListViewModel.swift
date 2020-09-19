//
//  FavoriteListViewModel.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez on 08/08/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import Foundation
import Combine
import CoreData

class FavoriteListViewModel : ObservableObject {
    
    lazy var favorites : [Follower] = []
    var persistenceService : PersistenceService
    
    init(persistenceService: PersistenceService) {
        self.persistenceService = persistenceService
    }
    
//    public func getFavorites(completion: @escaping (Result<[Follower], FGError>)-> Void){
//        persistenceService.retrieveFavorites { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case.success(let favorites):
//                self.favorites = favorites
//                completion(.success(favorites))
//            case.failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
    
    public func getFavorites(completion: @escaping (Result<[Follower], FGError>)-> Void){
        persistenceService.basicFetchRequest { favorites in
            switch favorites {
            case .success(let manageObjects) :
                _ = manageObjects.map {
                    let follower = Follower(login: ($0.value(forKey: "login") as? String)!, avatarUrl: ($0.value(forKey: "avatarUrl") as? String)!)
                    self.favorites.append(follower)
                }
                completion(.success(self.favorites))
            case .failure(let error) :
                completion(.failure(error))
            }
        }
    }
    
    func updateFavoriteList(favorite: Follower, completion: @escaping (String?) -> Void) {
        persistenceService.update(favorite: favorite, actionType: .removing) { error in
            guard let error = error else  {
                completion(nil)
                return
            }
             completion(error.rawValue)
        }
    }
}
