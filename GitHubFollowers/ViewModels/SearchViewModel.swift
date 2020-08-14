//
//  SearchViewModel.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez on 07/08/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import Foundation

class SearchViewModel {
    
    //typealias ValidationCallBack = (_ isvalid: Bool,_ message: String) -> Void
    
    //var validationCallBack : ValidationCallBack?
    
    func validateUserName(for userName: String, completion: (_ isvalid: Bool, _ message: String) -> Void) {
        if !userName.isEmpty {
            completion(true, "")
        } else {
            completion(false, "Please enter a username . We need to know who to look for 😀")
        }
    }
}
