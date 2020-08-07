//
//  SearchViewModel.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez on 07/08/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import Foundation

class SearchViewModel: NSObject{
    
    var user : User?
    
    var username: String? {
        return user?.login
    }
    
    private var isUserNameEmpty : Bool? {
        return username?.isEmpty
    }
    
    typealias ValidationCallBack = (_ isvalid: Bool,_ message: String) -> Void
    
    var validationCallBack : ValidationCallBack?
    
    func validateUserName(for userName: String) -> Void {
        guard let isValid = isUserNameEmpty else {
            self.validationCallBack?(false, "Please enter a username . We need to know who to look for 😀")
            return
        }
        
        validationCallBack?(isValid, "")
    }
    
    func validationCompletionHandler(callBack: @escaping ValidationCallBack) {
        self.validationCallBack = callBack
    }
    
}
