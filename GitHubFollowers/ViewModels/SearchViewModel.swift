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
    
    var isValidUserName: AnyPublisher<Bool, Never> {
        $userName
            .removeDuplicates()
            .map { !$0.isEmpty }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
