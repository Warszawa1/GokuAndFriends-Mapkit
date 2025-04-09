//
//  MockSecureDataProvider.swift
//  GokuAndFriendsTests
//
//  Created by Ire  Av on 9/4/25.
//

import Foundation
@testable import GokuAndFriends


class MockSecureDataProvider: SecureDataProtocol {
    let keyToken = "keytoken"
    let userDefaults = UserDefaults.standard
    
    func getToken() -> String? {
        userDefaults.value(forKey: keyToken) as? String
    }
    
    func setToken(_ token: String) {
        userDefaults.setValue(token, forKey: keyToken)
    }
    
    func clearToken() {
        userDefaults.removeObject(forKey: keyToken)
    }
}
