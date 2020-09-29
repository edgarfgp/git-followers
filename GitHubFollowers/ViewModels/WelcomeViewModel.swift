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
                let urlString = "https://api.github.com/user/repos"
                let url = URL(string: urlString)!
                var request = URLRequest(url: url)
                request.addValue("Bearer \(credential.oauthToken)", forHTTPHeaderField: "Authorization")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.httpMethod = "GET"
                
                URLSession.shared.dataTask(with: request) { (data, response, error) in
                            
                            if let _ = error {
                                return
                            }
                            
                            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                                return
                            }
                            
                            guard let data = data else {
                                return
                            }
                    
                            let json = String(data: data, encoding: .utf8) ?? "Invalid JSON"
                            
                            do {
                                let object = try JSON(string: json)

                                for item in object {
                                    if let repo = item.html_url.optionalString{
                                        print(repo)
                                    }
                                    
                                }
                                
                            }catch (let ex) {
                                print(ex.localizedDescription)
                            }
                            
                        }.resume()
            case .failure(let error):
                print(error.rawValue)
            }
        }
    }
}
