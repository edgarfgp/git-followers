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

    public lazy var gitHubService = GitHubService()
    private var cancellables = Set<AnyCancellable>()
    
    func fetchUserInfoData(username: String, completion : @escaping (Result<User, FGError>) -> Void){
        self.gitHubService.fetchUserInfo(urlString: username)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completionResult in
                switch completionResult {
                case .failure(let error) :
                    completion(.failure(error))
                case .finished : break
                }
            }) { result in
                completion(.success(result))
        }.store(in: &cancellables)
    }
}
