//
//  ErrorMessages.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 30/01/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import Foundation

enum ErrorMessage : String {
    
    case invalidUserName  = "This username created a invalid request"
    case unableToComplte =  "Unable to complete your reauest. Plase check your connection"
    case invalidResponse =  "Invalid response from the server. Please try again later."
    case invalidData = "The data recieved from the server is invalid. Please try again"
    
    
}
