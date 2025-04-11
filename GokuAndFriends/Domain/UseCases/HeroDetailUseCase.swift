//
//  HeroDetailUseCase.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 9/4/25.
//
import Foundation

protocol HeroDetailUseCaseProtocol {
    func fetchLocationsForHeroWith(id: String, completion: @escaping (Result<[HeroLocation], GAFError>) -> Void)
    func fetchTransformationsForHeroWith(id: String, completion: @escaping (Result<[Transformation], GAFError>) -> Void)
}

class HeroDetailUseCase: HeroDetailUseCaseProtocol {
    
    private var storedData: StoreDataProvider
    private var apiProvider: ApiProvider
    
    init(storedData: StoreDataProvider = .shared, apiProvider: ApiProvider = .init()) {
        self.storedData = storedData
        self.apiProvider = apiProvider
    }
    
    func fetchLocationsForHeroWith(id: String, completion: @escaping (Result<[HeroLocation], GAFError>) -> Void) {
        print("🔍 Fetching locations for hero with ID: \(id)")
        
        // First check if we have locations stored in Core Data
        let locationsHero = storedLocationsForHeroWith(id: id)
        print("📊 Found \(locationsHero.count) stored locations for hero")
        
        // Debug stored locations if available
        if locationsHero.isEmpty {
            apiProvider.fetchLocationForHeroWith(id: id) { [weak self] result in
                switch result {
                case .success(let locations):
                    DispatchQueue.main.async {
                        self?.storedData.insert(locations: locations)
                        let bdLocations = self?.storedLocationsForHeroWith(id: id) ?? []
                        completion(.success(bdLocations))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.success(locationsHero))
        }
    }
    
    func fetchTransformationsForHeroWith(id: String, completion: @escaping (Result<[Transformation], GAFError>) -> Void) {
        print("🔍 Fetching transformations for hero with ID: \(id)")
        
        // For now, return an empty array or implement the API call
        apiProvider.fetchTransformationsForHeroWith(id: id) { result in
            switch result {
            case .success(let apiTransformations):
                let transformations = apiTransformations.map { api -> Transformation in
                    return Transformation(
                        id: api.id,
                        name: api.name,
                        description: api.description,
                        photo: api.photo
                    )
                }
                completion(.success(transformations))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func storedLocationsForHeroWith(id: String) -> [HeroLocation] {
        // Create a predicate to find the hero by ID
        let predicate = NSPredicate(format: "identifier == %@", id)
        
        // Fetch the hero
        guard let hero = storedData.fetchHeroes(filter: predicate).first,
              let locations = hero.locations else {
            return []
        }
        return locations.map({$0.mapToHeroLocation()})
    }
    
    private func storedTransformationsForHeroWith(id: String) -> [Transformation] {
            // This would be implemented based on your data model
            return []
        }
}
