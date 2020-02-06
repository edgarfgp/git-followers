//
//  ErrorMessages.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 30/01/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import Foundation

enum FGError : String, Error {
    
    case invalidUserName  = "This username created a invalid request"
    case unableToComplte =  "Unable to complete your reauest. Plase check your connection"
    case invalidResponse =  "Invalid response from the server. Please try again later."
    case invalidData = "The data recieved from the server is invalid. Please try again"
    case unableToFavourite = "There was an error favouriting this user. Please try again"
    case alreadyInfavourites = "You already favotited this user"
}
