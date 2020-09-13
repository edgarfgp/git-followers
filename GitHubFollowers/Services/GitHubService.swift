//
//  NetworkManager.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 29/01/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit
import Combine

class GitHubService {
    
    private let numberOfRetries : Int = 1
    private let cache = NSCache<NSString, UIImage>()
    private var  cancellables = Set<AnyCancellable>()
    private let apiQueue = DispatchQueue(label: "API", qos: .default, attributes: .concurrent)
    
    func fetchFollowers(userName: String, page: Int, completion: @escaping (Result<[Follower], FGError>) -> Void){
        let urlString = URLConstants.baseURL + "\(userName)/followers?per_page=100&page=\(page)"
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        URLSession.shared.dataTaskPublisher(for: URL(string: urlString)!)
            .retry(numberOfRetries)
            .map(\.data)
            .decode(type: [Follower].self, decoder: decoder)
            .catch { _ in Empty<[Follower], FGError>() }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .finished : break
                }
            }, receiveValue: { user in
                completion(.success(user))
            })
            .store(in: &cancellables)
    }
    
    func fetchUserInfo(urlString : String, completion: @escaping (Result<User, FGError>) -> Void){
        let urlString = URLConstants.baseURL + "\(urlString)"
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        URLSession.shared.dataTaskPublisher(for: URL(string: urlString)!)
            .retry(numberOfRetries)
            .map(\.data)
            .decode(type: User.self, decoder: decoder)
            .catch { _ in Empty<User, FGError>() }
            .receive(on: apiQueue)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .finished : break
                }
                
            }, receiveValue: { user in
                completion(.success(user))
            })
            .store(in: &cancellables)
    }
    
    func fetchImage(from urlString: String, completion: @escaping (UIImage) -> Void) {
        URLSession.shared.dataTaskPublisher(for: URL(string: urlString)!)
            .retry(numberOfRetries)
            .tryMap { data, response -> UIImage in
                
                let cacheKey = NSString(string: urlString)
                
                if let image = self.cache.object(forKey: cacheKey) {
                    return image
                }
                
                guard let image = UIImage(data: data) else {
                    throw FGError.invalidData
                }
                self.cache.setObject(image, forKey: cacheKey)
                return image
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { _ in }) { imageResult in
            completion(imageResult)
        }.store(in: &cancellables)
    }
}
