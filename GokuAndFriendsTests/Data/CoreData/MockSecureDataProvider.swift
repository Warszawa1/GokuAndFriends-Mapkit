//
//  MockSecureDataProvider.swift
//  GokuAndFriendsTests
//
//  Created by Ire  Av on 9/4/25.
//

import Foundation
@testable import GokuAndFriends


class MockSecureDataProvider: SecureDataProtocol {
    var clearTokenCalled = false
    var tokenValue: String? = nil
    
    func getToken() -> String? {
        return tokenValue
    }
    
    func setToken(_ token: String) {
        tokenValue = token
    }
    
    func clearToken() {
        clearTokenCalled = true
        tokenValue = nil
    }
}



