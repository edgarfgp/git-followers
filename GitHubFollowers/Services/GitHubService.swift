//
//  NetworkManager.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 29/01/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit
import Combine
import OAuthSwift

protocol IGitHubService {
    func fetchFollowers(userName: String, page: Int) -> AnyPublisher<[Follower], FGError>
    func fetchUserInfo(urlString : String) -> AnyPublisher<User, FGError>
    func fetchImage(from urlString: String) -> AnyPublisher<UIImage, FGError>
}

class GitHubService : IGitHubService {
    
    private let numberOfRetries : Int = 1
    private let cache = NSCache<NSString, UIImage>()
    private var cancellables = Set<AnyCancellable>()
    private let apiQueue = DispatchQueue(label: "API", qos: .default, attributes: .concurrent)
    private var oauthswift: OAuth2Swift?
    
    private lazy var oauthConfiguration : OAuth2Swift? = {
        return OAuth2Swift(
            consumerKey:    AppConfig.consumerKey,
            consumerSecret: AppConfig.consumerSecret,
            authorizeUrl:   AppConfig.authorizeURL,
            accessTokenUrl: AppConfig.accessTokenUrl,
            responseType:   AppConfig.responseType)
    }()
    
    
    func fetchFollowers(userName: String, page: Int) -> AnyPublisher<[Follower], FGError>{
        let urlString = URLConstants.baseURL + "/users/\(userName)/followers?per_page=100&page=\(page)"
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
        let urlString = URLConstants.baseURL + "/users/\(urlString)"
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
    
    public func fetchAuthRepos(credential:String) -> AnyPublisher<[Repo], FGError> {
        let url = URL(string: URLConstants.baseURL + "/user/repos")!
        let authRequest = addAtuhHeaders(url: url, token: credential)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return URLSession.shared.dataTaskPublisher(for: authRequest)
            .retry(numberOfRetries)
            .map(\.data).decode(type: [Repo].self, decoder: decoder)
            .print("Debug -->")
            .catch { _ in Empty<[Repo], FGError>() }
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
    
    func authenticateUser(completion: @escaping (Result<OAuthSwiftCredential, FGError>) -> Void) {
        self.oauthswift = oauthConfiguration
        self.oauthswift?.authorizeURLHandler = WebViewController();
        _ = self.oauthswift?.authorize(withCallbackURL: URL(string: AppConfig.callBackURL)!, scope:AppConfig.scope, state: AppConfig.state, completionHandler: { result in
            switch result {
            case .success(let (credential, _, _)):
                completion(.success(credential))
            case .failure(let error):
                print("GitHub OAuth Error \(error.localizedDescription)")
                completion(.failure(.unableToAutheticateUser))
            }
        })
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
                  
              }catch{
                  completed(.failure(.invalidData))
              }
          }.resume()
      }
}

extension GitHubService {
    
    private func addAtuhHeaders(url : URL, token: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        return request
    }
    
}

//.tryMap { request   in
//    guard let data = request.data as Data? else { throw FGError.invalidData}
//    guard let response = request.response as? HTTPURLResponse, response.statusCode == 200 else {
//        throw FGError.invalidResponse
//    }
//    guard let json = String(data: data, encoding: .utf8) else { throw FGError.unableToDeserialize }
//    let result = try JSON(string: json)
//    return User(login: result.login.string, avatarUrl: result.avatar_url.string, name: result.name.string, location:result.location.string, bio: result.bio.string, publicRepos: result.public_repos.int, publicGists: result.public_gists.int, htmlUrl:result.html_url.string, following: result.following.int, followers: result.followers.int, createdAt: Date())
//}
