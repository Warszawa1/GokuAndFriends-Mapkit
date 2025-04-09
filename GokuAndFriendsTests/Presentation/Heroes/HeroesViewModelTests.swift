//
//  HeroesViewModelTests.swift
//  GokuAndFriendsTests
//
//  Created by Ire  Av on 8/4/25.
//

import XCTest
@testable import GokuAndFriends

class MockHeroesUseCase: HeroesUseCaseProtocol {
    func loadHeroes(completion: @escaping (Result<[Hero], GAFError>) -> Void) {
        do {
            let urlData = try XCTUnwrap(Bundle(for: ApiProviderTest.self).url(forResource: "Heroes", withExtension: "json"))
            let data = try Data(contentsOf: urlData)
            let response = try JSONDecoder().decode([ApiHero].self, from: data)
            completion(.success(response.map({$0.mapToHero()})))
        } catch {
            completion(.failure(.errorParsingData))
        }
    }
}

class MockHeroesUseCaseError: HeroesUseCaseProtocol {
    func loadHeroes(completion: @escaping (Result<[Hero], GAFError>) -> Void) {
        completion(.failure(.noDataReceived))
    }
}

final class HeroesViewModelTests: XCTestCase {
    
    var sut: HeroesViewModel!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func testLoadData() {
        // Given
        var expectedHeroes: [Hero] = []
        sut = HeroesViewModel(useCase: MockHeroesUseCase(), storedData: .sharedTesting)
        
        // When
        let expectation = expectation(description: "ViewModel loads heroes and informs")
        sut.stateChaged = { [weak self] state in
            switch state {
            case .dataUpdated:
                expectedHeroes = self?.sut.fetchHeroes() ?? []
                expectation.fulfill()
            case .errorLoadingHeroes(error: _):
                XCTFail("Waiting for success")
            }
        }
        sut.loadData()
        
        // Then
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(expectedHeroes.count, 15)

    }
    
    // todo testLogOut **************************************************************
}

extension ApiHero {
    func mapToHero() -> Hero {
        Hero.init(id: self.id,
                  name: self.name,
                  description: self.description,
                  photo: self.photo)
    }
}
