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
    case heroes (name: String)
    case locations(id: String)
    
    
    var isAuthoritationRequired: Bool {
        switch self {
        case .heroes, .locations:
            return true
//        default:
//            return false
        }
    }
    
    func path() -> String {
        switch self {
        case .heroes:
            return "/api/heros/all"
        case .locations:
            return "/api/heros/locations"
        }
    }
    
    func httpMethod() -> String {
        switch self {
        case .heroes, .locations:
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
        }
    }
}
