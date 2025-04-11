//
//  HeroDetailViewModel.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 11/4/25.
//

import Foundation


enum HeroDetailState {
    case locationsUpdated
    case transformationsUpdated
    case errorLoadingLocation(error: GAFError)
    case errorLoadingTransformations(error: GAFError)
}

class HeroDetailViewModel {
    
    private var useCase: HeroDetailUseCaseProtocol
    private var locations: [HeroLocation] = []
    private var transformations: [Transformation] = []
    var hero: Hero
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
        loadTransformations()
    }
    
    private func loadTransformations() {
            useCase.fetchTransformationsForHeroWith(id: hero.id) { [weak self] result in
                switch result {
                case .success(let transformations):
                    self?.transformations = transformations
                    self?.stateChanged?(.transformationsUpdated)
                case .failure(let error):
                    self?.stateChanged?(.errorLoadingTransformations(error: error))
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
    
    func getTransformations() -> [Transformation] {
            return transformations
        }
}
