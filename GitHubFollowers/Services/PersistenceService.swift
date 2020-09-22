//
//  PersistenceManager.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 05/02/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit
import CoreData

enum PersistenceActionType {
    case removing
    case adding
}

enum Keys {
    static let favorite = "Favorite"
    static let login = "login"
    static let avatarUrl = "avatarUrl"
}

struct PersistenceService {
    
    private var manageObjectContext : NSManagedObjectContext {
        return AppDelegate.persistenceContainer.viewContext
    }
    
    func update(favorite: Follower, actionType: PersistenceActionType, completed: @escaping (FGError?) -> Void){
        getFavorites { result in
            
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
                
                saveFavorite(login: favorite.login, imageUrl: favorite.avatarUrl) { errorResult in
                    completed(errorResult)
                }
                
            case .failure(let error):
                completed(error)
            }
        }
    }
    
    private func saveFavorite(login: String, imageUrl: String, completed: @escaping (FGError?) -> Void) {
        let favorite = Favorite(context: manageObjectContext)
        favorite.login = login
        favorite.avatarUrl = imageUrl
        
        do {
            try manageObjectContext.save()
            completed(nil)
        } catch {
            completed(.unableToFavorite)
        }
    }
    
    func getFavorites(completion: @escaping (Result<[Follower], FGError>) -> Void) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Keys.favorite)
        
        do {
            let manageObjects = try manageObjectContext.fetch(fetchRequest)
            let favorites = manageObjects.compactMap {
                return Follower(login: ($0.value(forKey: Keys.login) as? String)!, avatarUrl: ($0.value(forKey: Keys.avatarUrl) as? String)!)
            }
            
            completion(.success(favorites))
            
        } catch {
            completion(.failure(.unableToFavorite))
        }
    }
}
