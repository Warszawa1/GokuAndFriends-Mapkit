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
    
    func performLoginRequest(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        // No need for do-catch if nothing throws
        // Create login string in the required format
        let loginString = String(format: "%@:%@", email, password)
        guard let loginData = loginString.data(using: .utf8) else {
            completion(.failure(NSError(domain: "LoginAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error encoding credentials"])))
            return
        }
        let base64LoginString = loginData.base64EncodedString()
        
        // Create URL
        guard let url = URL(string: "https://dragonball.keepcoding.education/api/auth/login") else {
            completion(.failure(NSError(domain: "LoginAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network error
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Debug response
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Login response body: \(responseString)")
            }
            
            // Check HTTP status code
            if let httpResponse = response as? HTTPURLResponse {
                print("Login response code: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(NSError(domain: "LoginAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Credenciales incorrectas"])))
                    return
                }
            }
            
            // Parse response data
            guard let data = data else {
                completion(.failure(NSError(domain: "LoginAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "No se recibieron datos del servidor"])))
                return
            }
            
            // Based on your previous implementation, it seems the API returns the token directly as text
            if let token = String(data: data, encoding: .utf8) {
                // Return the token
                completion(.success(token))
            } else {
                completion(.failure(NSError(domain: "LoginAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Formato de respuesta incorrecto"])))
            }
        }.resume()
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
    
    func fetchTransformationsForHeroWith(id: String, completion: @escaping (Result<[ApiTransformation], GAFError>) -> Void) {
        do {
            let request = try requestBuilder.build(endpoint: .transformations(id: id))
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


