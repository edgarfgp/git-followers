//
//  GitHubServicesTests.swift
//  GitHubFollowersTests
//
//  Created by Edgar Gonzalez on 15/09/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import XCTest
import Combine
@testable import GitHubFollowers

class GitHubServicesTests: XCTestCase {
    
    func test_fetchFollowers_always_returnsFollowers() {
        let mockService = GitHubService()
        let result = expectValue(of: mockService.fetchFollowers(userName: "", page: 0),
                                 equals: [[Follower(login: "Edgar", avatarUrl: "Avatar1")]])
                
        mockService.fetchFollowersSub.send([Follower(login: "Edgar", avatarUrl: "Avatar1")])
        
        wait(for: [result.expectation], timeout: 1)
    }
}

private class GitHubService: IGitHubService {
    let fetchFollowersSub = PassthroughSubject<[Follower], FGError>()
    let fetchUserSub = PassthroughSubject<User, FGError>()
    let fetchImageSub = PassthroughSubject<UIImage, FGError>()
    
    func fetchUserInfo(urlString: String) -> AnyPublisher<User, FGError> {
        fetchUserSub.eraseToAnyPublisher()
    }
    
    func fetchImage(from urlString: String) -> AnyPublisher<UIImage, FGError> {
        fetchImageSub.eraseToAnyPublisher()
    }
    
    
    func fetchFollowers(userName: String, page: Int) -> AnyPublisher<[Follower], FGError> {
        fetchFollowersSub.eraseToAnyPublisher()
    }
}
