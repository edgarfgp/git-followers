//
//  SearchViewModel.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez on 07/08/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import Foundation
import Combine

class SearchViewModel {
    
    @Published var isButtonEnabled : Bool = false
    @Published var userName : String = ""
    
    var validUsername: AnyPublisher<Bool, Never> {
        return $userName
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map{!$0.isEmpty}
            .eraseToAnyPublisher()
    }
}
