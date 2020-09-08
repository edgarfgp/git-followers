//
//  GitHubFollowersTests.swift
//  GitHubFollowersTests
//
//  Created by Edgar Gonzalez on 08/08/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import XCTest
@testable import GitHubFollowers

class SearchViewModelTests: XCTestCase {
    
    func testUserNameIsInitializeToEmty(){
        let viewModel = SearchViewModel()
        
        viewModel.userName = "edgarfgp"
        
        XCTAssertFalse(viewModel.userName.isEmpty)
    }
}
