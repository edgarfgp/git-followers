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
    private let cache = NSCache<NSString, UIImage>()
    private var  cancellables = Set<AnyCancellable>()
    private let apiQueue = DispatchQueue(label: "API", qos: .default, attributes: .concurrent)
    
    func fetchFollowers(userName: String, page: Int) -> AnyPublisher<[Follower], FGError> {
        let userName = URLConstants.baseURL + "\(userName)/followers?per_page=100&page=\(page)"
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return URLSession.shared.dataTaskPublisher(for: URL(string: userName)!)
            .receive(on: apiQueue)
            .map{ $0.data }
            .decode(type:[Follower].self, decoder: decoder)
            .catch { _ in Empty<[Follower], FGError>() }
            .eraseToAnyPublisher()
    }
    
    func fetchUserInfo(for userName: String) -> AnyPublisher<User, FGError> {
        let urlString = URLConstants.baseURL + "\(userName)"
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return URLSession.shared.dataTaskPublisher(for: URL(string: urlString)!)
            .receive(on: apiQueue)
            .map{ $0.data }
            .decode(type: User.self, decoder: decoder)
            .catch { _ in Empty<User, FGError>() }
            .eraseToAnyPublisher()
        
    }
    
    func fetchImage(from urlString: String, completed: @escaping(UIImage?) -> Void) {
        
        let cacheKey = NSString(string: urlString)
        
        if let image = cache.object(forKey: cacheKey) {
            completed(image)
            return
        }
        
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
                
                self.cache.setObject(image, forKey: cacheKey)
                
                completed(image)
        }.store(in: &cancellables)
    }
}


extension GitHubService {
    
    func getFollowers(for userName: String, page: Int, completed: @escaping  (Result<[Follower], FGError>) -> Void) {
        let userName = URLConstants.baseURL + "\(userName)/followers?per_page=100&page=\(page)"
        fetchData(for: userName, completed: completed)
        
    }
    
    func getUserInfo(for userName: String, completed: @escaping  (Result<User, FGError>) -> Void) {
        let userName = URLConstants.baseURL + "\(userName)"
        fetchData(for: userName, completed: completed)
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
        
        let task = URLSession.shared.downloadTask(with: url) { [weak self] location , response, error in
            
            guard let  self = self else {
                completed(nil)
                return
            }
            
            if error != nil { return }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(nil)
                return
            }
            
            guard let location = location else { return }
            
            guard let imageData = try? Data(contentsOf: location) else { return }
                        
            guard let image = UIImage(data: imageData) else {
                completed(nil)
                return
            }
            
            self.cache.setObject(image, forKey: cacheKey)
            
            completed(image)
        }
        
        task.resume()
    }
    
    func fetchData<T: Decodable>(for urlString : String, completed: @escaping (Result<T, FGError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completed(.failure(.invalidUserName))
            
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let _ = error {
                completed(.failure(.unableToComplete))
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
                let result = try decoder.decode(T.self, from: data)
                completed(.success(result))
                
            }catch {
                completed(.failure(.invalidData))
            }
        }.resume()
    }
    
}
