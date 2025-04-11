//
//  HTTPMethods.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 6/4/25.
//

import Foundation

enum HTTPMethods: String {
    case POST, GET, PUT, DELETE
}

enum GAFEndpoint {
    case heroes(name: String)
    case locations(id: String)
    case login(username: String, password: String)
    case transformations(id: String)
    

    var isAuthoritationRequired: Bool {
        switch self {
        case .heroes, .locations, .transformations:
            return true
        case .login:
            return false  // Login doesn't require authorization
        }
    }
    
    func path() -> String {
        switch self {
        case .heroes:
            return "/api/heros/all"
        case .locations:
            return "/api/heros/locations"
        case .login:
            return "/api/auth/login"  // Login endpoint path
        case .transformations:
            return "/api/heros/tranformations" // Note: Check the API for the exact path
        }
    }
    
    func httpMethod() -> String {
        switch self {
        case .heroes, .locations, .login, .transformations:
            return HTTPMethods.POST.rawValue
        }
    }
    
    func params() -> Data? {
        switch self {
        case .heroes(name: let name):
            let attributes = ["name": name]
            let data = try? JSONSerialization.data(withJSONObject: attributes)
            return data
            
        case .locations(id: let id):
            let attributes = ["id": id]
            let data = try? JSONSerialization.data(withJSONObject: attributes)
            return data
            
        case .login(username: let username, password: let password):
            let attributes = ["email": username, "password": password]
            let data = try? JSONSerialization.data(withJSONObject: attributes)
            return data
            
        case .transformations(id: let id):
            let attributes = ["id": id]
            let data = try? JSONSerialization.data(withJSONObject: attributes)
            return data
        }
    }
}
