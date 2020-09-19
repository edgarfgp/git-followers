//
//  PersistenceManager.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 05/02/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit
import CoreData

extension UserDefaults {
    
    @objc dynamic var favorites: Int {
        return integer(forKey: "backgroundColorValue")
    }
    
}

enum PersistenceActionType {
    case removing
    case adding
}

class PersistenceService {
    
    static let shared = PersistenceService()
    
    private let defaults = UserDefaults.standard
    
    enum Keys {
        static let favorites = "favorites"
    }
    
    private init() {}
    
    func update(favorite: Follower, actionType: PersistenceActionType, completed: @escaping (FGError?) -> Void){
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
                
                completed(self.save(favorites: retriecedFavorites))
                
            case .failure(let error):
                completed(error)
            }
        }
    }
    
    func retrieveFavorites(completed: @escaping (Result<[Follower], FGError>) -> Void) {
        
        guard let favoritesData = defaults.object(forKey: Keys.favorites) as? Data else {
            completed(.success([]))
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let favorites = try decoder.decode([Follower].self, from: favoritesData)
            completed(.success(favorites))
        } catch {
            completed(.failure(.unableToFavorite))
        }
    }
    
    func save(favorites: [Follower]) -> FGError? {
        
        do{
            let encoder = JSONEncoder()
            let encodedFavorites = try encoder.encode(favorites)
            defaults.set(encodedFavorites, forKey: Keys.favorites)
            return nil
            
        }catch {
            return FGError.unableToFavorite
        }
    }
    
    func SaveFavorite(login: String, imageUrl: String, completed: @escaping (FGError?) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistenceContainer.viewContext
        let favorite = Favorite(context: context)
        favorite.login = login
        favorite.avatarUrl = imageUrl
        
        do {
            try context.save()
            completed(nil)
        } catch {
            completed(.unableToFavorite)
        }
    }
    
    func basicFetchRequest(completion: @escaping (Result<[NSManagedObject], FGError>) -> Void) {
        guard let appDelegate =  UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistenceContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Favorite")
    
        do {
            let favorites = try managedContext.fetch(fetchRequest)
            completion(.success(favorites))
        } catch {
            completion(.failure(.unableToFavorite))
        }
    }
    
}
