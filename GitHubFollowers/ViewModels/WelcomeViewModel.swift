//
//  WelcomeViewModel.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez on 29/09/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import Foundation

class WelcomeViewModel {
    private var githubService : GitHubService
    init(githubService : GitHubService) {
        self.githubService = githubService
    }
    
    public func authenticateWithGitHub() {
        githubService.authenticateUser { authResult in
            switch authResult {
            case .success(let credential):
                self.githubService.fetchAuthRepos(credential: credential.oauthToken)
                break
            case .failure(let error):
                print(error.rawValue)
            }
        }
    }
}
