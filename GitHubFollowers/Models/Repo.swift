//
//  Repos.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez on 30/09/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import Foundation

// MARK: - Repo
struct Repo: Codable {
    let name : String
    let fullName: String
    let repoPrivate: Bool?
    let htmlURL: String?
    let repoDescription: String?
    let createdAt : Date
    let language: String
    let hasPages: Bool
    let forksCount: Int
    let openIssuesCount: Int
}
