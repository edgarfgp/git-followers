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
        persistenceService.getFavorites { [weak self] resultFavorites in
            guard let self = self else { return }
            switch resultFavorites {
            case .success(let result) :
                self.favorites = result
                completion(.success(result))
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
