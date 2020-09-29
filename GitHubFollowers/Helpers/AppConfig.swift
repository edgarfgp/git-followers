//
//  AppConfig.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez on 29/09/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import Foundation
import OAuthSwift

class AppConfig
{
    static let consumerKey:String = "05a5bd8f3f62bdda3d23"
    static let consumerSecret:String = "7dbf0995cdad7d0ba1ed73fe19528813e1edcfcd"
    static let authorizeURL:String = "https://github.com/login/oauth/authorize"
    static let accessTokenUrl:String = "https://github.com/login/oauth/access_token"
    static let responseType:String = "code"
    static let callBackURL:String = "oauth-github-followers://oauth-callback/github"
    static let scope:String = "user,repo"
    static let state:String = generateState(withLength: 20)
}
