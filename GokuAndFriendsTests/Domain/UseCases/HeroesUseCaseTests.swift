//
//  HeroesUseCaseTests.swift
//  GokuAndFriendsTests
//
//  Created by Ire  Av on 8/4/25.
//

import XCTest
@testable import GokuAndFriends


final class HeroesUseCaseTests: XCTestCase {
    
    var sut: HeroesUseCase!
    var storedData: StoreDataProvider!
    var secureData: SecureDataProtocol!
    let expectedToken = "token"

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        storedData = .sharedTesting
    
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        secureData = MockSecureDataProvider()
        let requestBuilder = RequestBuilder(secureData: secureData)
        let apiProvider = ApiProvider(session: session, requestBuilder: requestBuilder)
        sut = HeroesUseCase(apiProvider: apiProvider, storedData: storedData)
        secureData.setToken(expectedToken)
    }

    override func tearDownWithError() throws {
        // Limpiar al finalizar cada test el estado de sut y MockURLProtocol
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = nil
        storedData.clearBBDD()
        sut = nil
        secureData.clearToken()
        try super.tearDownWithError()
    }

    func testLoadHeroes_shouldReturnAscendingOrder() throws {
        // Given
        var expectedHeroes: [Hero] = []
        MockURLProtocol.requestHandler = { request in
            let urlData = try XCTUnwrap(Bundle(for: ApiProviderTest.self).url(forResource: "Heroes", withExtension: "json"))
            let data = try Data(contentsOf: urlData)
            
            let urlRequest = try XCTUnwrap(request.url)
            let response = try XCTUnwrap(MockURLProtocol.httpResponse(url: urlRequest, statusCode: 200))
            
            return (response, data)
        }
        let initialCountHeroesInDDBB = storedData.numHeroes()
        
        // When
        let expectation = expectation(description: "Use case return heroes")
        sut.loadHeroes { result in
            switch result {
            case .success(let heroes):
                expectedHeroes = heroes
                expectation.fulfill()
            case .failure(_):
                XCTFail("Waiting for success")
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 0.1)
        
        let finalHeroesCountInDDBB = storedData.numHeroes()
        
        XCTAssertEqual(initialCountHeroesInDDBB, 0 )
        XCTAssertEqual(finalHeroesCountInDDBB, 15)
        XCTAssertEqual(expectedHeroes.count, 15)
        
        
        let hero = try XCTUnwrap(expectedHeroes.first)
        
        XCTAssertEqual(hero.name, "Androide 17")
//        XCTAssertEqual(hero.favorite, true)
        XCTAssertEqual(hero.id, "963CA612-716B-4D08-991E-8B1AFF625A81")
        let expectedDesc = "Es el hermano gemelo de Androide 18. Son muy parecidos físicamente, aunque Androide 17 es un joven moreno. También está programado para destruir a Goku porque fue el responsable de exterminar el Ejército Red Ribbon. Sin embargo, mató a su creador el Dr. Gero por haberle convertido en un androide en contra de su voluntad. Es un personaje con mucha confianza en sí mismo, sarcástico y rebelde que no se deja pisotear. Ese exceso de confianza le hace cometer errores que pueden costarle la vida"
        XCTAssertEqual(hero.description, expectedDesc)
        XCTAssertEqual(hero.photo, "https://cdn.alfabetajuega.com/alfabetajuega/2019/10/dragon-ball-androide-17.jpg?width=300")
        
        
    }
}
