//
//  LoginUseCase.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 11/4/25.
//

import Foundation

protocol LoginUseCaseProtocol {
    func execute(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
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
                self?.secureDataProvider.setToken(token)
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

