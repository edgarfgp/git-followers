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
    
    init(persistenceService: PersistenceService = PersistenceService()) {
        self.persistenceService = persistenceService
    }
    
    public func getFavorites(completion: @escaping (Result<[Follower], FGError>)-> Void){
        persistenceService.getFavorites { favorites in
            switch favorites {
            case .success(let favorites) :
                self.favorites = favorites
                completion(.success(favorites))
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
