//
//  UserInfoViewModel.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez on 08/08/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import Foundation
import Combine

class UserInfoViewModel {
    public var userSubject = PassthroughSubject<User, FGError>()
    public var gitHubService : GitHubService
    @Published public var username : String = ""
    init(_ gitHubService : GitHubService) {
        self.gitHubService = gitHubService
    }
            
    func fetchUserInfoData(){
        gitHubService.fetchUserInfo(for: username) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.userSubject.send(user)
            case .failure(let error):
                self.userSubject.send(completion: .failure(error))
            }
        }
    }
}
