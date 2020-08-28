//
//  SearchViewModel.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez on 07/08/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import Foundation
import Combine

class SearchViewModel : ObservableObject {
    @Published var userName : String = ""
    
    private let userNameSubject = CurrentValueSubject<Bool, Never>(false)
    
    var isValidUserName: AnyPublisher<Bool, Never> {
        return userNameSubject.eraseToAnyPublisher()
    }
    
    func validateUserName(userName: String){
        self.userName = userName
        userNameSubject.send(!userName.isEmpty)
    }
}
