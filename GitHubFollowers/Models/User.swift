//
//  User.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 29/01/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import Foundation

struct User : Codable {
    
    var login: String
    
    var avatarUrl: String
    
    var name: String?
    
    var location: String?
    
    var bio: String?
    
    var publicRepos: Int
    
    var publicGists: Int
    
    var htmlUrl: String
    
    var following: Int
    
    var followers: Int
    
    var createdAt: String
}
