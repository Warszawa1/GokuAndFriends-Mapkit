//
//  MockApiProvider.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 12/4/25.
//

import Foundation
@testable import GokuAndFriends

class MockLoginApiProvider {
    let shouldSucceed: Bool
    var loginCalled = false
    
    init(shouldSucceed: Bool) {
        self.shouldSucceed = shouldSucceed
    }
    
    func performLoginRequest(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        loginCalled = true
        
        if shouldSucceed {
            completion(.success("test-token-123"))
        } else {
            let error = NSError(domain: "LoginAPI", code: 401, userInfo: [NSLocalizedDescriptionKey: "Credenciales incorrectas"])
            completion(.failure(error))
        }
    }
}
