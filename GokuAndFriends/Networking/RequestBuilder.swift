//
//  RequestBuilder.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 6/4/25.
//

import Foundation


struct RequestBuilder {
    let host = "dragonball.keepcoding.education"
    
    private var secureData: SecureDataProtocol
    
    init(secureData: SecureDataProtocol = SecureDataProvider()) {
        self.secureData = secureData
    }
    
    func url(endPoint: GAFEndpoint) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = self.host
        components.path = endPoint.path()
        return components.url
    }
    
    func build(endpoint: GAFEndpoint) throws(GAFError) -> URLRequest {
        guard let url = url(endPoint: endpoint) else {
            throw .barUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod()
        if endpoint.isAuthoritationRequired {
            guard let token = secureData.getToken() else {
                throw .sessionTokenMissed
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        }
        
        
        request.setValue("application/json, charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = endpoint.params()
        
        
        return request
        
    }
}
