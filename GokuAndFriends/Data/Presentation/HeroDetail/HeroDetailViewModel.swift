//
//  HeroDetailViewModel.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 11/4/25.
//

import Foundation


enum HeroDetailState {
    case locationsUpdated
    case errorLoadingLocation(error: GAFError)
}

class HeroDetailViewModel {
    
    private var useCase: HeroDetailUseCaseProtocol
    private var locations: [HeroLocation] = []
    private var hero: Hero
    var stateChanged: ((HeroDetailState) -> Void)?
    
    
    init(hero: Hero, useCase: HeroDetailUseCaseProtocol = HeroDetailUseCase()) {
        self.hero = hero
        self.useCase = useCase
    }
    
    func loadData() {
        useCase.fetchLocationsForHeroWith(id: hero.id) { [weak self]  result in
            switch result {
            case .success(let locations):
                self?.locations = locations
                self?.stateChanged?(.locationsUpdated)
            case .failure(let error):
                self?.stateChanged?(.errorLoadingLocation(error: error))
            }
        }
    }
    
    func getHeroLocations() -> [HeroAnnotation] {
        var annotations: [HeroAnnotation] = []
        
        // Check if we have any valid locations from the API
        for location in locations {
            if let coordinate = location.coordinate {
                annotations.append(HeroAnnotation(coordinate: coordinate, title: hero.name))
            }
        }
        
        return annotations
    }
}
