//
//  Favorite+CoreDataProperties.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez on 17/09/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import Foundation
import CoreData

extension Favorite {
    @NSManaged var login : String
    @NSManaged var avatarUrl : String
}
