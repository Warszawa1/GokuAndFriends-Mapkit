//
//  LoginUseCase.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 11/4/25.
//

import Foundation

protocol LoginUseCaseProtocol {
    func execute(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
    
    #if DEBUG
    func checkKeychainStatus() -> String
    #endif
}

final class LoginUseCase: LoginUseCaseProtocol {
    private let apiProvider: ApiProvider
    private let secureDataProvider: SecureDataProtocol
    
    init(apiProvider: ApiProvider = ApiProvider(),
         secureDataProvider: SecureDataProtocol = SecureDataProvider()) {
        self.apiProvider = apiProvider
        self.secureDataProvider = secureDataProvider
    }
    
    func execute(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        apiProvider.performLoginRequest(email: username, password: password) { [weak self] result in
            switch result {
            case .success(let token):
                print("Token received: \(token.prefix(10))...") // Log the first part of the token
                self?.secureDataProvider.setToken(token)
                
                // Verify token was saved successfully
                #if DEBUG
                if let savedToken = self?.secureDataProvider.getToken() {
                    print("✅ KEYCHAIN: Token saved successfully (\(savedToken.prefix(10))...)")
                } else {
                    print("❌ KEYCHAIN: Failed to save token")
                }
                #endif
                
                completion(.success(()))
            case .failure(let error):
                print("❌ LOGIN ERROR: \(error.localizedDescription)")
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

