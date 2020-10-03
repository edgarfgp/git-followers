//
//  AppConfig.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez on 29/09/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import Foundation
import OAuthSwift

enum AppConfig
{
    static let consumerKey: String = ""
    static let consumerSecret: String = ""
    static let authorizeURL: String = "https://github.com/login/oauth/authorize"
    static let accessTokenUrl: String = "https://github.com/login/oauth/access_token"
    static let responseType: String = "code"
    static let callbackUrlString: String = "oauth-github-followers"
    static let callBackURL: String = "oauth-github-followers://oauth-callback/github"
    static let scope: String = "user,repo"
    static let state: String = generateState(withLength: 20)
}
