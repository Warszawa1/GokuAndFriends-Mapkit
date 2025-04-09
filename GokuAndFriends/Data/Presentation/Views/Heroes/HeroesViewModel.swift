//
//  HeroesViewModel.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 6/4/25.
//

import Foundation


enum HeroesState {
    case dataUpdated
    case errorLoadingHeroes(error: GAFError)
}

class HeroesViewModel {
    private var heroes: [Hero] = []
    private var useCase: HeroesUseCaseProtocol
    private var storedData: StoreDataProvider
    private var secureData: SecureDataProtocol
    
    var stateChaged: ((HeroesState) -> Void)?
    
    init(useCase: HeroesUseCaseProtocol = HeroesUseCase(),
         storedData: StoreDataProvider = .shared,
         secureData: SecureDataProtocol = SecureDataProvider()) {
        self.useCase = useCase
        self.storedData = storedData
        self.secureData = secureData
    }
    
    func loadData() {
        useCase.loadHeroes { [weak self] result in
            switch result {
            case .success(let heroes):
                self?.heroes = heroes
                self?.stateChaged?(.dataUpdated)
            case .failure(let error):
                self?.stateChaged?(.errorLoadingHeroes(error: error))
            }
        }
    }
    
    func fetchHeroes() -> [Hero] {
        return heroes
    }
    
    func performLogout() {
        secureData.clearToken()
        storedData.clearBBDD()
    }
}
