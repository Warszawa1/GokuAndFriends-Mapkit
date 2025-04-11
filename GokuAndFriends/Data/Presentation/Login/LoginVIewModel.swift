//
//  LoginVIewModel.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 11/4/25.
//

import Foundation

enum LoginState: Equatable {
    case initial
    case success
    case loading
    case error(reason: String)
}

class LoginViewModel {
    private let loginUseCase: LoginUseCaseProtocol
    private var secureData: SecureDataProtocol
    
    var onStateChanged: ((LoginState) -> Void)?
    private(set) var state: LoginState = .initial {
        didSet {
            onStateChanged?(state)
        }
    }
    
    init(loginUseCase: LoginUseCaseProtocol = LoginUseCase(),
         secureData: SecureDataProtocol = SecureDataProvider()) {
        self.loginUseCase = loginUseCase
        self.secureData = secureData
    }
    
    func login(username: String?, password: String?) {
        guard let username = username, !username.isEmpty else {
            state = .error(reason: "El usuario no puede estar vacío")
            return
        }
        
        guard let password = password, !password.isEmpty else {
            state = .error(reason: "La contraseña no puede estar vacía")
            return
        }
        
        state = .loading
        
        loginUseCase.execute(username: username, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.state = .success
                case .failure(let error):
                    self?.state = .error(reason: error.localizedDescription)
                }
            }
        }
    }
    
    // For testing purposes
//    func useTestToken() {
//        let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImtpZCI6InByaXZhdGUifQ.eyJlbWFpbCI6ImlhbnRlbG9AdW9jLmVkdSIsImV4cGlyYXRpb24iOjY0MDkyMjExMjAwLCJpZGVudGlmeSI6IjM2REFFNkRDLTEzQUYtNEM5RS1CRTIyLUM1QzgwRTA1NUVBRiJ9.zQ5ebMCRtMbPjNlHipzzJIDD0sY-4tq4htYNmaAfRJw"
//        secureData.setToken(token)
//        state = .success
//    }
}
