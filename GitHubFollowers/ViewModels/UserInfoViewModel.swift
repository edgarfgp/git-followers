//
//  UserInfoViewModel.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez on 08/08/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import Foundation
import Combine

class UserInfoViewModel : ObservableObject {
    @Published var user : User?
    public var gitHubService : GitHubService
    
    init(gitHubService : GitHubService) {
        self.gitHubService = gitHubService
    }
    
    func fetchUserInfoData(username: String){
        self.gitHubService.fetchUserInfo(urlString: username) { [weak self] userInfo in
            switch userInfo {
            case .success(let user) :
                self?.user = user
                
            case .failure( _) : break
            }
        }
    }
}
