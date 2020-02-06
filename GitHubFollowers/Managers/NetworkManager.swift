//
//  NetworkManager.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 29/01/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit

class NetworkManager {
    
    static let shared = NetworkManager()
    
    private let baseURL = "https://api.github.com/users/"
    
    let cache = NSCache<NSString, UIImage>()
    
    private init(){}
    
    func getFollowers(for userName: String, page: Int, completed: @escaping  (Result<[Follower], FGError>) -> Void) {
        let userName = baseURL + "\(userName)/followers?per_page=100&page=\(page)"
        
        guard let url = URL(string: userName) else {
            completed(.failure(.invalidUserName))
            
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
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
            
        }
        
        task.resume()
    }
    
    
    func getUserInfo(for userName: String, completed: @escaping  (Result<User, FGError>) -> Void) {
        let userName = baseURL + "\(userName)"
        
        guard let url = URL(string: userName) else {
            completed(.failure(.invalidUserName))
            
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
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
            
        }
        
        task.resume()
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
