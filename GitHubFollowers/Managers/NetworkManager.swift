//
//  NetworkManager.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 29/01/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    let baseURL = "https://api.github.com/users/"
    
    private init(){}
    
    func getFollowers(for userName: String, page: Int, completed: @escaping  ([Follower]?, String?) -> Void) {
        let endPoint = baseURL + "\(userName)/followers?=per_page=10&page=\(page)"
        
        guard let url = URL(string: endPoint) else {
            completed(nil, "This username created a invalid request")
            
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let _ = error {
                completed(nil, "Unable to complete your reauest. Plase check your connection")
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(nil, "Invalid response from the server. Please try again later.")
                return
            }
            
            guard let data = data else {
                completed(nil, "The data recieved from the server is invalid. Please try again")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let followers = try decoder.decode([Follower].self, from: data)
                completed(followers, nil)
                
            }catch {
                completed(nil, "The data recieved from the server is invalid. Please try again")
            }
            
        }
        
        task.resume()
    }
}
