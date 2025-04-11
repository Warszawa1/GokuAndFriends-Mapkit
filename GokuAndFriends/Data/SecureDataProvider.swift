//
//  SecureDataProvider.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 8/4/25.
//

import Foundation
import KeychainSwift

protocol SecureDataProtocol {
    func getToken() -> String?
    func setToken(_ token: String)
    func clearToken()
    func deleteToken()
    
}

struct SecureDataProvider: SecureDataProtocol {
    
    private let keyToken = "keyToken"
    private let keyChain = KeychainSwift()
    
    func getToken() -> String? {
        keyChain.get(keyToken)
    }
    
    func setToken(_ token: String) {
        keyChain.set(token, forKey: keyToken)
    }
    
    func clearToken() {
        keyChain.delete(keyToken)
    }
    
    func deleteToken() {
        clearToken()
    }
}
