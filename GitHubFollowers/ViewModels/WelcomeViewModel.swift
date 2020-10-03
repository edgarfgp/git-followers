//
//  WelcomeViewModel.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez on 29/09/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import Foundation
import Combine
import KeychainSwift

class WelcomeViewModel {
    private var githubService : GitHubService
    private var cancelables = Set<AnyCancellable>()
    
    init(githubService : GitHubService) {
        self.githubService = githubService
    }
    
    public func authenticateWithGitHub() {
        githubService.authenticateUser { [weak self] authResult in
            guard let self = self else { return }
            switch authResult {
            case .success(let credential):
                let keychain = KeychainSwift()
                if ((keychain.get("oauthToken")?.isEmpty) != nil){
                    keychain.set(credential.oauthToken, forKey: "oauthToken")
                }
                
                print(keychain.allKeys)
                self.githubService.fetchAuthRepos(credential: credential.oauthToken)
                    .sink { reveivedCompletion in
                        switch reveivedCompletion {
                        case .failure(let error):
                            print(error.rawValue)
                        case .finished : break
                        }
                        
                    } receiveValue: { repos in
                        let result = repos.filter{ $0.language.lowercased().contains("C#".lowercased()) }
                        print(result)
                    }.store(in: &self.cancelables)

                    
                
                break
            case .failure(let error):
                print(error.rawValue)
            }
        }
    }
}
