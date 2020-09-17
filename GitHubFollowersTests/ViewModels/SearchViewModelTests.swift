//
//  GitHubFollowersTests.swift
//  GitHubFollowersTests
//
//  Created by Edgar Gonzalez on 08/08/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import XCTest
import Combine
@testable import GitHubFollowers

class SearchViewModelTests: XCTestCase {
    let viewModel = SearchViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    override func tearDown() {
        subscriptions = []
    }
    
    func test_WithEmptyUserName_AlwaysReturnsIsValidUserNameFalse(){
        
        viewModel.userName = ""
        
        viewModel.isValidUserName.sink(receiveValue: { value  in
            XCTAssertFalse(value)
        }).store(in: &subscriptions)
    }
    
    func test_WithValidUserName_AlwaysReturnsIsValidUserNameTrue(){
        
        viewModel.userName = "edgarfgp"
        
        viewModel.isValidUserName.sink(receiveValue: { value  in
            XCTAssertTrue(value)
        }).store(in: &subscriptions)
    }
}
