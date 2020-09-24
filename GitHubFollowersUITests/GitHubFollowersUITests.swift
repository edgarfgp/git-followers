//
//  GitHubFollowersUITests.swift
//  GitHubFollowersUITests
//
//  Created by Edgar Gonzalez on 24/09/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import XCTest

class GitHubFollowersUITests: XCTestCase {
    
    private var app : XCUIApplication!
    
    override func setUp() {
        app = XCUIApplication()
        app.launch()
    }
    
    func testgivenImInTheSearchbar_WhenIseeIt_ThenIExpecToSeeTheCorrectElements() throws {
        let userNameEntry = app.textFields.matching(identifier: "userNameTextFiled").firstMatch
        let followerButton = app.buttons.matching(identifier: "fgButton").firstMatch
        
        guard  let userNameEntryText = userNameEntry.placeholderValue else { return }
        
        XCTAssertEqual(userNameEntryText, "Enter a valid User")
        XCTAssertEqual(followerButton.label, "Get Followers")
    }
    
    func testgivenImInTheSearchbar_WhenIEnterAValidUserNameAndPressGetFollowers_ThenIExpecToNavigateToFollowowerList() throws {
        let userNameEntry = app.textFields.matching(identifier: "userNameTextFiled").firstMatch
        
        userNameEntry.tap()
        userNameEntry.typeText("Edgarfgp")
        app.keyboards.buttons["go"].tap()
        
        XCTAssert(app.navigationBars["Edgarfgp"].exists)
    }
    
    func test_givenIamInTheSeachTab_whenINavigateToFavoriteTab_ThenISeeTheCorrectTab() throws {
        let favoriteTabBar = app.tabBars["Tab Bar"].buttons["Favorites"]
        favoriteTabBar.tap()
        
        XCTAssert(favoriteTabBar.exists)
        XCTAssert(app.navigationBars["Favorites"].exists)
    }
    
    func test_givenIamInThefavoritesTab_whenINavigateToSearchTab_ThenISeeTheCorrectTab() throws {
        let searchTabBar = app.tabBars["Tab Bar"].buttons["Search"]
        searchTabBar.tap()
        
        XCTAssert(searchTabBar.exists)
    }
}
