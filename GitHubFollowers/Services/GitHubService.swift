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
    
    static let shared = GitHubService()
    
    private let baseURL = "https://api.github.com/users/"
    
    let cache = NSCache<NSString, UIImage>()
    
    private var  cancellables = Set<AnyCancellable>()
    
    func fetchFollowers(userName: String, page: Int, completed: @escaping  (Result<[Follower], FGError>) -> Void) {
        let userName = baseURL + "\(userName)/followers?per_page=100&page=\(page)"
        guard let url = URL(string: userName) else {
            completed(.failure(.invalidUserName))
            return
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { request in
                guard let data = request.data as Data? else { completed(.failure(.invalidData))}
                guard let response = request.response as? HTTPURLResponse, response.statusCode == 200 else {
                    completed(.failure(.invalidResponse))
                    throw HTTPError.statusCode
                }
                return data
        }
        .decode(type:[Follower].self, decoder: decoder)
        .sink(receiveCompletion: { result in
            switch result {
            case .failure(let error):
                if let _ = error as Error? {
                    completed(.failure(.unableToComplte))
                    return
                }
            case .finished : break
            }
            
        }, receiveValue: { followers in
            completed(.success(followers))
        })
            .store(in: &cancellables)
    }
    
    func fetchUserInfo(for userName: String, completed: @escaping  (Result<User, FGError>) -> Void) {
        let urlString = baseURL + "\(userName)"
        guard let url = URL(string: urlString) else {
            completed(.failure(.invalidUserName))
            return
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { request   in
                guard let data = request.data as Data? else { completed(.failure(.invalidData))}
                guard let response = request.response as? HTTPURLResponse, response.statusCode == 200 else {
                    completed(.failure(.invalidResponse))
                    throw HTTPError.statusCode
                }
                
                return data
        }.decode(type: User.self, decoder: decoder)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    if let _ = error as Error? {
                        completed(.failure(.unableToComplte))
                        return
                    }
                case .finished : break
                }
                
            }, receiveValue: { user in
                completed(.success(user))
            })
            .store(in: &cancellables)
    }
    
    func fetchImage(from urlString: String, completed: @escaping(UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completed(nil)
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data}
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(_):
                    completed(nil)
                case .finished : break
                }
                
            }) { data in
                guard let image = UIImage(data: data) else {
                    completed(nil)
                    return
                }
                completed(image)
        }.store(in: &cancellables)
    }
}


extension GitHubService {
    
    func getFollowers(for userName: String, page: Int, completed: @escaping  (Result<[Follower], FGError>) -> Void) {
        let userName = baseURL + "\(userName)/followers?per_page=100&page=\(page)"
        
        guard let url = URL(string: userName) else {
            completed(.failure(.invalidUserName))
            
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let _ = error {
                completed(.failure(.unableToComplte))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let followers = try decoder.decode([Follower].self, from: data)
                completed(.success(followers))
                
            }catch {
                completed(.failure(.invalidData))
            }
            
        }.resume()
        
    }
    
    func getUserInfo(for userName: String, completed: @escaping  (Result<User, FGError>) -> Void) {
        let userName = baseURL + "\(userName)"
        
        guard let url = URL(string: userName) else {
            completed(.failure(.invalidUserName))
            
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let _ = error {
                completed(.failure(.unableToComplte))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.dateDecodingStrategy = .iso8601
                let user = try decoder.decode(User.self, from: data)
                completed(.success(user))
                
            }catch {
                completed(.failure(.invalidData))
            }
            
        }.resume()
    }
    
    func downloadImage(from urlString: String, completed: @escaping(UIImage?) -> Void) {
        
        let cacheKey = NSString(string: urlString)
        
        if let image = cache.object(forKey: cacheKey) {
            completed(image)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completed(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            guard let  self = self else {
                completed(nil)
                return
            }
            
            if error != nil { return }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(nil)
                return
            }
            
            guard let data = data else {
                completed(nil)
                return
            }
            
            guard let image = UIImage(data: data) else {
                completed(nil)
                return
            }
            
            self.cache.setObject(image, forKey: cacheKey)
            
            completed(image)
        }
        
        task.resume()
    }
    
}
