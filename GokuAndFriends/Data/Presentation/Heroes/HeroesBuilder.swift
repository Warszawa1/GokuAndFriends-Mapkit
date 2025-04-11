//
//  HeroesBuilder.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 11/4/25.
//

import UIKit

final class HeroesBuilder {
    static func build() -> UIViewController {
        let useCase = HeroesUseCase()
        let viewModel = HeroesViewModel(useCase: useCase)
        let viewController = HeroesController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        return navigationController
    }
}
