//
//  HeroesUseCase.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 6/4/25.
//

import Foundation


protocol HeroesUseCaseProtocol {
    func loadHeroes(completion: @escaping (Result<[Hero], GAFError>) -> Void)
}
    
class HeroesUseCase: HeroesUseCaseProtocol {
    
    private var apiProvider: ApiProvider
    private var storedData: StoreDataProvider
    
    init(apiProvider: ApiProvider = ApiProvider(), storedData: StoreDataProvider = .shared) {
        self.apiProvider = apiProvider
        self.storedData = storedData
    }
    
    func loadHeroes(completion: @escaping (Result<[Hero], GAFError>) -> Void) {
        let localHeros = loadHeroes()
        if loadHeroes().isEmpty {
            // Usamos el servicio
            apiProvider.fetchHeroes { [weak self] result in
                switch result {
                case .success(let apiHeroes):
                    self?.storedData.context.performAndWait {
                        self?.storedData.insert(heroes: apiHeroes)
                        completion(.success(self?.loadHeroes() ?? []))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.success(localHeros))
        }
    }
    
    
    private func loadHeroes() -> [Hero] {
        
//     Predicate's use to filter items (DDBB) (search for heroes/use case)
//        let filter = NSPredicate(format: "name CONTAINS[cd] %@", "a")
//        let heroes = storedData.fetchHeroes(filter: filter)

        
        let heroes = storedData.fetchHeroes(filter: nil)
        return heroes.map({$0.mapToHero()})
    }
}
