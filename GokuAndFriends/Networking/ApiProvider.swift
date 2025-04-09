//
//  ApiProvider.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 5/4/25.
//

import Foundation


struct ApiProvider {
    var session: URLSession
    var requestBuilder: RequestBuilder
    
    init(session: URLSession = .shared, requestBuilder: RequestBuilder = .init()) {
        self.session = session
        self.requestBuilder = requestBuilder
        
    }
    
    
    func fetchHeroes(name: String = "", completion: @escaping (Result<[ApiHero], GAFError>) -> Void) {
        
        do {
            let request = try requestBuilder.build(endpoint: .heroes(name: name))
            manageResponse(request: request, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchLocationForHeroWith(id: String, completion: @escaping (Result<[ApiHeroLocation], GAFError>) -> Void) {
        do {
            let request = try requestBuilder.build(endpoint: .locations(id: id))
            manageResponse(request: request, completion: completion)

        } catch {
            completion(.failure(error))
        }
    }
    
    func manageResponse<T: Codable>(request: URLRequest, completion: @escaping (Result<T, GAFError>) -> Void) {
        session.dataTask(with: request) { data, response ,error in
            if let error {
                completion(.failure(.serverError(error: error)))
            }
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            
            guard statusCode == 200 else {
                completion(.failure(.responseError(code: statusCode)))
                return
            }
            
            guard let data else {
                completion(.failure(.noDataReceived))
                return
            }
            do {
                let response = try JSONDecoder().decode(T.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(.errorParsingData))
            }
        }.resume()
    }
}


