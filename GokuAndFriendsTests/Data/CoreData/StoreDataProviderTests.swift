//
//  StoreDataProviderTests.swift
//  GokuAndFriendsTests
//
//  Created by Ire  Av on 7/4/25.
//

import XCTest
@testable import GokuAndFriends

final class StoreDataProviderTests: XCTestCase {
    
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
    
    func testInsertHeroes() throws {
        // Given
        let expectedHero = createHero()
        let initialCount = sut.fetchHeroes(filter: nil).count
        
        // When
        sut.insert(heroes: [expectedHero])
        
        // Then
        let finalCount = sut.fetchHeroes(filter: nil).count
        XCTAssertEqual(initialCount, 0)
        XCTAssertEqual(finalCount, 1)
        
        
        let hero = try XCTUnwrap(sut.fetchHeroes(filter: nil).first)
        
        XCTAssertEqual(hero.name, expectedHero.name)
        XCTAssertEqual(hero.info, expectedHero.description)
        XCTAssertEqual(hero.photo, expectedHero.photo)
        XCTAssertTrue(hero.favorite)
        XCTAssertNotNil(hero.identifier)
    }
    
    func testFetchHeroes_shouldReturnHeroesOrderedAscending() throws {
        // Given
        let hero1 = createHero(with: "Mark")
        let hero2 = createHero(with: "George")
        sut.insert(heroes: [hero1, hero2])

        // When
        let heroes = sut.fetchHeroes(filter: nil, sortAscending: true)
        
        // Then
        let firstHero = try XCTUnwrap(heroes.first)
        XCTAssertEqual(firstHero.name, hero2.name)
    }
    
    func testFetchHeroesShouldFilterItems() throws {
        // Given
        let hero1 = createHero(with: "Mark")
        let hero2 = createHero(with: "George")
        sut.insert(heroes: [hero1, hero2])
        let filter = NSPredicate(format: "name CONTAINS[cd] %@", "M")
        
        // When
        let heroes = sut.fetchHeroes(filter: filter)
        
        // Then
        XCTAssertEqual(heroes.count, 1)
        let hero = try XCTUnwrap(heroes.first)
        XCTAssertEqual(hero.name, hero1.name)
    }
    
    private func createHero(with name: String = "Name") -> ApiHero {
        ApiHero(id: UUID().uuidString,
                favorite: true,
                name: name,
                description: "description",
                photo: "photo")
    }
}
