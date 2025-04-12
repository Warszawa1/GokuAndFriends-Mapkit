//
//  ApiProviderTest.swift
//  GokuAndFriendsTests
//
//  Created by Ire  Av on 7/4/25.
//

import XCTest
@testable import GokuAndFriends




final class ApiProviderTest: XCTestCase {
    
    var sut: ApiProvider!
    var secureData: SecureDataProtocol!
    let expectedToken = "token"

    override func setUpWithError() throws {
        // Creamosla URLSession usando nuestro Mock de URLProtocol en la config
        try super.setUpWithError()
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        secureData = MockSecureDataProvider()
        let requestBuilder = RequestBuilder(secureData: secureData)
        sut = ApiProvider(session: session, requestBuilder: requestBuilder)
        
    }

    override func tearDownWithError() throws {
        // Limpiar al finalizar cada test el estado de sut y MockURLProtocol
        MockURLProtocol.requestHandler = nil
        MockURLProtocol.error = nil
        sut = nil
        secureData.clearToken()
        try super.tearDownWithError()
    }
    
    
    
    func testfetchHeroes() throws {
        // Given
        var expectedHeroes: [ApiHero] = []
        
        
        // Inicializamos el MockURLProtocol
        var receivedRequest: URLRequest?
        
        MockURLProtocol.requestHandler = { request in
            // Guardamos en una var la rquest que nos devuelve el mock para validaciones posteriores.
            receivedRequest = request
            
            let urlData = try XCTUnwrap(Bundle(for: ApiProviderTest.self).url(forResource: "Heroes", withExtension: "json"))
            let data = try Data(contentsOf: urlData)
            
            let urlRequest = try XCTUnwrap(request.url)
            let response = try XCTUnwrap(MockURLProtocol.httpResponse(url: urlRequest, statusCode: 200))
            
            return (response, data)
        }
        
        // When
        secureData.setToken(expectedToken)
        let expectation = expectation(description: "load heroes")
        sut.fetchHeroes { result in
            switch result {
            case .success(let heroes):
                expectation.fulfill()
                expectedHeroes = heroes
            case .failure(_):
                XCTFail("Waiting for success")
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertEqual(receivedRequest?.url?.absoluteString, "https://dragonball.keepcoding.education/api/heros/all")
        XCTAssertEqual(receivedRequest?.httpMethod, "POST")
        XCTAssertEqual(receivedRequest?.value(forHTTPHeaderField: "Content-Type"), "application/json, charset=utf-8")
        XCTAssertEqual(receivedRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer \(expectedToken)")

    
        XCTAssertEqual(expectedHeroes.count, 15)
        let hero = try XCTUnwrap(expectedHeroes.first)
        
        XCTAssertEqual(hero.name, "Maestro Roshi")
        XCTAssertEqual(hero.id, "14BB8E98-6586-4EA7-B4D7-35D6A63F5AA3")
        XCTAssertEqual(hero.photo, "https://cdn.alfabetajuega.com/alfabetajuega/2020/06/Roshi.jpg?width=300")
        XCTAssertFalse(hero.favorite!)
        let expectedDesc = "Es un maestro de artes marciales que tiene una escuela, donde entrenará a Goku y Krilin para los Torneos de Artes Marciales. Aún en los primeros episodios había un toque de tradición y disciplina, muy bien representada por el maestro. Pero Muten Roshi es un anciano extremadamente pervertido con las chicas jóvenes, una actitud que se utilizaba en escenas divertidas en los años 80. En su faceta de experto en artes marciales, fue quien le enseñó a Goku técnicas como el Kame Hame Ha"
        XCTAssertEqual(hero.description, expectedDesc)
    }
    
    
    func testfetchHeroes_ServerError() {
        // Given
        MockURLProtocol.error = NSError(domain: "io.keepcodin.B19", code: 503)
        var expectedError: GAFError?
        
        
        // When
        let expectation = expectation(description: "load heroes fail")
//        expectation.assertForOverFulfill = false
        sut.fetchHeroes { result in
            switch result {
            case .success(_):
                XCTFail("Waiting for failure")
            case .failure(let error):
                expectedError = error
                expectation.fulfill()
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 0.1)
        XCTAssertNotNil(expectedError)
    }
    
    // Test de la función de fetchHeroes cuando recibe un error de status Code
    // Decidimos el startusCode al crear el response
    func testFechtHeroes_StatusCodeError() {
        // Given
        var expectedError: GAFError?
        
        MockURLProtocol.requestHandler = { request in
            let urlData = try XCTUnwrap(Bundle(for: ApiProviderTest.self).url(forResource: "Heroes", withExtension: "json"))
            let data = try Data(contentsOf: urlData)
            
            let urlRequest = try XCTUnwrap(request.url)
            let response = try XCTUnwrap(MockURLProtocol.httpResponse(url: urlRequest, statusCode: 401))
            
            return (response, data)
        }
        
        // When
        let expectation = expectation(description:" Load heroes fails with status Code 401")
        sut.fetchHeroes { result in
            switch result {
            case .success(_):
                XCTFail("Waiting for failure")
            case .failure(let error):
                expectedError = error
                expectation.fulfill()
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 0.1)
        XCTAssertNotNil(expectedError)
    }
    
            
    
    func testFetchTransformations() throws {
        // Given
        var expectedTransformations: [ApiTransformation] = []
        
        // Create a mock response directly from your Postman example
        let jsonData = """
        [
            {
                "name": "4. Super Saiyajin 3",
                "id": "D1C73353-5256-4AA1-B125-944D5C00A78B",
                "photo": "https://areajugones.sport.es/wp-content/uploads/2019/07/super-saiyajin-3-vegeta-a-maxima-potencia_1680217-1024x576.jpg.webp",
                "description": "Esta transformación es exclusiva de los videojuegos, ya que hemos podido verlo en Dragon Ball Heroes, Dragon Battlers, Raging Blast y su posterior secuela.",
                "hero": {
                    "id": "6E1B907C-EB3A-45BA-AE03-44FA251F64E9"
                }
            },
            {
                "name": "5. Super Saiyajin Dios",
                "id": "8E96F4B9-5BA8-43EC-895C-0086760E18C1",
                "photo": "https://areajugones.sport.es/wp-content/uploads/2019/07/vegetagod-1024x577.jpg.webp",
                "description": "Ésta sigue siendo una de las grandes incógnitas de Dragon Ball.",
                "hero": {
                    "id": "6E1B907C-EB3A-45BA-AE03-44FA251F64E9"
                }
            }
        ]
        """.data(using: .utf8)!
        
        // Set up the request handler
        var capturedRequest: URLRequest?
        
        MockURLProtocol.requestHandler = { request in
            // Store the complete request for later inspection
            capturedRequest = request
            
            let urlRequest = try XCTUnwrap(request.url)
            let response = try XCTUnwrap(MockURLProtocol.httpResponse(url: urlRequest, statusCode: 200))
            
            return (response, jsonData)
        }
        
        // When
        secureData.setToken(expectedToken)
        let heroId = "6E1B907C-EB3A-45BA-AE03-44FA251F64E9" // Vegeta's ID
        let expectation = expectation(description: "load transformations")
        
        sut.fetchTransformationsForHeroWith(id: heroId) { result in
            switch result {
            case .success(let transformations):
                expectedTransformations = transformations
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success but got failure: \(error)")
            }
        }
        
        // Wait for the async operation to complete
        wait(for: [expectation], timeout: 1.0)
        
        // Verify the request details
        XCTAssertNotNil(capturedRequest, "Request should have been captured")
        
        if let request = capturedRequest {
            XCTAssertEqual(request.url?.absoluteString, "https://dragonball.keepcoding.education/api/heros/tranformations")
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json, charset=utf-8")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(expectedToken)")
        }
        
        // Verify response data
        XCTAssertEqual(expectedTransformations.count, 2, "Should have 2 transformations")
        
        if let transformation = expectedTransformations.first {
            XCTAssertEqual(transformation.id, "D1C73353-5256-4AA1-B125-944D5C00A78B")
            XCTAssertEqual(transformation.name, "4. Super Saiyajin 3")
            XCTAssertNotNil(transformation.description)
            XCTAssertNotNil(transformation.photo)
            XCTAssertEqual(transformation.hero.id, "6E1B907C-EB3A-45BA-AE03-44FA251F64E9")
        }
    }
    
}
