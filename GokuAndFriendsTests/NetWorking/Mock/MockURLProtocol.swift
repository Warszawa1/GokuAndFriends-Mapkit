//
//  MockURLProtocol.swift
//  GokuAndFriendsTests
//
//  Created by Ire  Av on 7/4/25.
//

import Foundation


class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    static var error: Error?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let error = Self.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        
        guard let handler = Self.requestHandler else {
            fatalError("An error or request handler must be provided")
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    
    override func stopLoading() {}
    
    static func httpResponse(url: URL, statusCode: Int = 200) -> HTTPURLResponse? {
        HTTPURLResponse(url: url,
                        statusCode: statusCode,
                        httpVersion: nil,
                        headerFields: ["Content-Type": "application/json, charset=utf-8"])
    }
}
