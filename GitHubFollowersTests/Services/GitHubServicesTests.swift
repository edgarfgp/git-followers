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
    
    var cancellables = Set<AnyCancellable>()
    
    override func tearDown() {
      cancellables = []
    }

    func test_fetchFollowers_always_returnsFollowers() {
        let mockService = GitHubService()
        
        var result : [Follower]?
        
        mockService.fetchFollowers(userName: "", page: 0)
            .sink { _  in
            } receiveValue: { followers in
                result = followers
            }.store(in: &cancellables)

        let expected = [Follower(login: "Edgar", avatarUrl: "Avatar1")]
                
        mockService.fetchFollowersSub.send([Follower(login: "Edgar", avatarUrl: "Avatar1")])
        
        XCTAssertEqual(expected, result)
    }
    
    func test_fetchFollowersWithError_always_returnsCorrectError() {
        let mockService = GitHubService()
        var expectedResult : FGError?

        mockService.fetchFollowers(userName: "", page: 1)
            .sink { completionResult in
                switch completionResult {
                case .failure(let error) :
                    expectedResult = error
                case .finished : break
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)

        mockService.fetchFollowersSub.send(completion: .failure(FGError.invalidResponse))
        
        XCTAssertEqual(FGError.invalidResponse, expectedResult)
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
