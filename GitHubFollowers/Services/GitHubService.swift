//
//  NetworkManager.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 29/01/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit
import Combine

protocol IGitHubService {
    func fetchFollowers(userName: String, page: Int) -> AnyPublisher<[Follower], FGError>
    func fetchUserInfo(urlString : String) -> AnyPublisher<User, FGError>
    func fetchImage(from urlString: String) -> AnyPublisher<UIImage, FGError>
}

class GitHubService : IGitHubService {
    
    private let numberOfRetries : Int = 1
    private let cache = NSCache<NSString, UIImage>()
    private var  cancellables = Set<AnyCancellable>()
    private let apiQueue = DispatchQueue(label: "API", qos: .default, attributes: .concurrent)
    
    func fetchFollowers(userName: String, page: Int) -> AnyPublisher<[Follower], FGError>{
        let urlString = URLConstants.baseURL + "\(userName)/followers?per_page=100&page=\(page)"
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return URLSession.shared.dataTaskPublisher(for: URL(string: urlString)!)
            .retry(numberOfRetries)
            .map(\.data)
            .decode(type: [Follower].self, decoder: decoder)
            .catch { _ in Empty<[Follower], FGError>() }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchUserInfo(urlString : String) -> AnyPublisher<User, FGError>{
        let urlString = URLConstants.baseURL + "\(urlString)"
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return URLSession.shared.dataTaskPublisher(for: URL(string: urlString)!)
            .retry(numberOfRetries)
            .map(\.data)
            .decode(type: User.self, decoder: decoder)
            .catch { _ in Empty<User, FGError>() }
            .receive(on: apiQueue)
            .eraseToAnyPublisher()
    }
    
    func fetchImage(from urlString: String) -> AnyPublisher<UIImage, FGError>{
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
            .catch { _ in Empty<UIImage, FGError>() }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
