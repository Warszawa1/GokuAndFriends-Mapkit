//
//  LoginUseCaseTests.swift
//  GokuAndFriendsTests
//
//  Created by Ire  Av on 12/4/25.
//

import XCTest
@testable import GokuAndFriends

final class LoginUseCaseTests: XCTestCase {
    
    func testLoginSuccess_ShouldStoreToken() {
        // Given
        let mockSecureData = MockSecureDataProvider()
        let mockApiProvider = MockLoginApiProvider(shouldSucceed: true)
        let sut = TestableLoginUseCase(apiProvider: mockApiProvider, secureDataProvider: mockSecureData)
        
        // When
        let expectation = self.expectation(description: "Login success")
        sut.execute(username: "test@example.com", password: "password123") { result in
            if case .success = result {
                expectation.fulfill()
            } else {
                XCTFail("Expected success")
            }
        }
        
        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertNotNil(mockSecureData.getToken(), "Token should be stored after successful login")
        XCTAssertTrue(mockApiProvider.loginCalled, "Login API should be called")
    }
    
    func testLoginFailure_ShouldNotStoreToken() {
        // Given
        let mockSecureData = MockSecureDataProvider()
        let mockApiProvider = MockLoginApiProvider(shouldSucceed: false)
        let sut = TestableLoginUseCase(apiProvider: mockApiProvider, secureDataProvider: mockSecureData)
        
        // When
        let expectation = self.expectation(description: "Login failure")
        sut.execute(username: "test@example.com", password: "password123") { result in
            if case .failure = result {
                expectation.fulfill()
            } else {
                XCTFail("Expected failure")
            }
        }
        
        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertNil(mockSecureData.getToken(), "Token should not be stored after failed login")
        XCTAssertTrue(mockApiProvider.loginCalled, "Login API should be called")
    }
}

// Testable version of LoginUseCase that works with our mock
class TestableLoginUseCase: LoginUseCaseProtocol {
    private let apiProvider: MockLoginApiProvider
    private let secureDataProvider: SecureDataProtocol
    
    init(apiProvider: MockLoginApiProvider, secureDataProvider: SecureDataProtocol) {
        self.apiProvider = apiProvider
        self.secureDataProvider = secureDataProvider
    }
    
    func execute(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        apiProvider.performLoginRequest(email: username, password: password) { [weak self] result in
            switch result {
            case .success(let token):
                self?.secureDataProvider.setToken(token)
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    #if DEBUG
    func checkKeychainStatus() -> String {
        if let token = secureDataProvider.getToken() {
            return "✅ KEYCHAIN: Token exists (\(token.prefix(10))...)"
        } else {
            return "❌ KEYCHAIN: No token found"
        }
    }
    #endif
}
