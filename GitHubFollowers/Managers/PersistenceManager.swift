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

enum PersistenceManager {
    
    static private let defaults = UserDefaults.standard
    
    enum Keys {
        static let favourites = "favourites"
    }
    
    static func update(favorite: Follower, actionType: PersistenceActionType, completed: @escaping (FGError?) -> Void){
        retrieveFavourites { result in
            
            switch result {
                
            case .success(var retriecedFavourites):
                
                switch actionType {
                    
                case .adding:
                    guard !retriecedFavourites.contains(favorite) else {
                        completed(.alreadyInfavourites)
                        return
                    }
                    retriecedFavourites.append(favorite)
                    
                case .removing :
                    retriecedFavourites.removeAll { $0.login == favorite.login}
                }
                
                completed(save(favourites: retriecedFavourites))
                
            case .failure(let error):
                completed(error)
            }
        }
    }
    
    static func retrieveFavourites(completed: @escaping (Result<[Follower], FGError>) -> Void) {
        
        guard let favouritesData = defaults.object(forKey: Keys.favourites) as? Data else {
            completed(.success([]))
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let favourites = try decoder.decode([Follower].self, from: favouritesData)
            completed(.success(favourites))
        }catch{
            completed(.failure(.unableToFavourite))
        }
    }
    
    static func save(favourites: [Follower]) -> FGError? {
        do{
            let encoder = JSONEncoder()
            let encodedFavourites = try encoder.encode(favourites)
            defaults.set(encodedFavourites, forKey: Keys.favourites)
            return nil
            
        }catch {
            return FGError.unableToFavourite
        }
    }
}
