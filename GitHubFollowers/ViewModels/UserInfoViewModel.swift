//
//  UserInfoViewModel.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez on 08/08/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import Foundation

class UserInfoViewModel {
    public var gitHubService : GitHubService
    
    init(_ gitHubService : GitHubService) {
        self.gitHubService = gitHubService
    }
    
    typealias FetchUserInfoCallback =  (_ user : User?, _ error: FGError?) -> Void
    var fetchUserInfoCallback : FetchUserInfoCallback?
            
    func fetchUserInfoData(username : String){
        gitHubService.getUserInfo(for: username) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.fetchUserInfoCallback?(user, nil)
            case .failure(let error):
                self.fetchUserInfoCallback?(nil, error)
            }
        }
    }
}
