//
//  PersistenceManager.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 05/02/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit

enum PersistenceActionType {
    case removing
    case adding
}

enum PersistenceService {
    
    static private let defaults = UserDefaults.standard
    
    enum Keys {
        static let favorites = "favorites"
    }
    
    static func update(favorite: Follower, actionType: PersistenceActionType, completed: @escaping (FGError?) -> Void){
        retrieveFavorites { result in
            
            switch result {
                
            case .success(var retriecedFavorites):
                
                switch actionType {
                    
                case .adding:
                    guard !retriecedFavorites.contains(favorite) else {
                        completed(.alreadyInfavorites)
                        return
                    }
                    retriecedFavorites.append(favorite)
                    
                case .removing :
                    retriecedFavorites.removeAll { $0.login == favorite.login}
                }
                
                completed(save(favorites: retriecedFavorites))
                
            case .failure(let error):
                completed(error)
            }
        }
    }
    
    static func retrieveFavorites(completed: @escaping (Result<[Follower], FGError>) -> Void) {
        
        guard let favoritesData = defaults.object(forKey: Keys.favorites) as? Data else {
            completed(.success([]))
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let favorites = try decoder.decode([Follower].self, from: favoritesData)
            completed(.success(favorites))
        }catch{
            completed(.failure(.unableToFavorite))
        }
    }
    
    static func save(favorites: [Follower]) -> FGError? {
        
        do{
            let encoder = JSONEncoder()
            let encodedFavorites = try encoder.encode(favorites)
            defaults.set(encodedFavorites, forKey: Keys.favorites)
            return nil
            
        }catch {
            return FGError.unableToFavorite
        }
    }
}
