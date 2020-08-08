//
//  FavoriteListViewModel.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez on 08/08/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import Foundation

class FavoriteListViewModel {
    
    var persistenceService : PersistenceService
    
    typealias FetchFollowersCallback = (_ follower : [Follower]?, _ error : FGError?) -> Void
    typealias UpdateFavorireCallback = (_ message : String?) -> Void
    
    var getFavoritesCallback : FetchFollowersCallback?
    var updateFavoritesCallback : UpdateFavorireCallback?
    
    init(persistenceService: PersistenceService) {
        self.persistenceService = persistenceService
    }
    
    public func getFavorites(){
        persistenceService.retrieveFavorites { [weak self] result in
            guard let self = self else { return }
            switch result {
            case.success(let favorites):
                self.getFavoritesCallback?(favorites, nil)
            case.failure(let error):
                self.getFavoritesCallback?(nil, error)
            }
        }
    }
    
    func updateFavoriteList(favorite: Follower) {
        persistenceService.update(favorite: favorite, actionType: .removing) { [weak self] error in
            guard let self = self else { return }
            guard let error = error else  {
                self.updateFavoritesCallback?(nil)
                return
            }

            self.updateFavoritesCallback?(error.rawValue)
        }
    }
}
