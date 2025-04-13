//
//  OfflineDataTests.swift
//  GokuAndFriendsTests
//
//  Created by Ire  Av on 13/4/25.
//

import XCTest
@testable import GokuAndFriends

//<<** NEW TEST ********************************************************************>> 
final class OfflineDataTests: XCTestCase {
    
    private var sut: StoreDataProvider!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = .sharedTesting
    }

    override func tearDownWithError() throws {
        sut.clearBBDD()
        sut = nil
        try super.tearDownWithError()
    }
    
    func testFetchHeroesWhenOffline_shouldReturnLocalData() throws {
        // Given
        let expectedHero = createHero(with: "Goku")
        sut.insert(heroes: [expectedHero])
        
        // When
        let heroes = sut.fetchHeroes(filter: nil)
        
        // Then
        XCTAssertFalse(heroes.isEmpty, "Debería obtener héroes de Core Data")
        let hero = try XCTUnwrap(heroes.first)
        XCTAssertEqual(hero.name, expectedHero.name)
        XCTAssertEqual(hero.photo, expectedHero.photo)
        
        let heroesAgain = sut.fetchHeroes(filter: nil)
        XCTAssertEqual(heroesAgain.count, heroes.count, "La cantidad de héroes debería ser consistente")
    }
    
    private func createHero(with name: String = "Name") -> ApiHero {
        ApiHero(id: UUID().uuidString,
                favorite: true,
                name: name,
                description: "description",
                photo: "photo")
    }
}
