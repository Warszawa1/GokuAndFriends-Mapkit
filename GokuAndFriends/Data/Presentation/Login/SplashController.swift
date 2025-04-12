//
//  SplashController.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 3/4/25.
//

import UIKit

class SplashController: UIViewController {
    
    private var secureData = SecureDataProvider()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Small delay to ensure smooth transition from launch screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.checkAuthAndNavigate()
        }
    }
    
    private func checkAuthAndNavigate() {
        if secureData.getToken() != nil {
            let heroesVC = HeroesController()
            navigationController?.pushViewController(heroesVC, animated: false)
        } else {
            let loginController = LoginController()
            navigationController?.pushViewController(loginController, animated: true)
        }
    }
}
