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
    public var username : String = ""
    private var cancelables = Set<AnyCancellable>()
    
    init(gitHubService : GitHubService) {
        self.gitHubService = gitHubService
    }
    
    func fetchUserInfoData(){
        gitHubService.fetchUserInfo(for: username)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    self.userSubject.send(completion: .failure(error))
                case .finished: break
                }
            }) { user in
                self.userSubject.send(user)
        }.store(in: &cancelables)
    }
}
