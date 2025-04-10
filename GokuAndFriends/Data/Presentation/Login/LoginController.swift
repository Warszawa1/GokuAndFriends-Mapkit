//
//  LoginController.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 3/4/25.
//

import UIKit

class LoginViewModel {
    let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImtpZCI6InByaXZhdGUifQ.eyJlbWFpbCI6ImlhbnRlbG9AdW9jLmVkdSIsImV4cGlyYXRpb24iOjY0MDkyMjExMjAwLCJpZGVudGlmeSI6IjM2REFFNkRDLTEzQUYtNEM5RS1CRTIyLUM1QzgwRTA1NUVBRiJ9.zQ5ebMCRtMbPjNlHipzzJIDD0sY-4tq4htYNmaAfRJw"
    private var secureData: SecureDataProtocol
    
    init(secureData: SecureDataProtocol = SecureDataProvider()) {
        self.secureData = secureData
    }
    
    func saveToken() {
        secureData.setToken(token)
        
    }
}

class LoginController: UIViewController {
    
    private var viewModel: LoginViewModel
    
    init(viewModel: LoginViewModel = .init()) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: LoginController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        let heroes = StoreDataProvider.shared.fetchHeroes(filter: nil)
//        if heroes.isEmpty {
//            testApiHeroes()
//        } else {
//            debugPrint("Heroes from Data Base")
//            print(heroes.map({$0.name}))
//            testApiLocations()
//        }
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        viewModel.saveToken()
        let heroesVC = HeroesController()
        navigationController?.pushViewController(heroesVC, animated: true)
    }
    
    
    func testApiHeroes() {
        let apiProvider = ApiProvider()
        
        apiProvider.fetchHeroes { result in
            switch result {
            case .success(let heroes):
                print("Data from Service")
                print(heroes.map({$0.name}))
                StoreDataProvider.shared.insert(heroes: heroes)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    func testApiLocations() {
        let apiProvider = ApiProvider()
        
        apiProvider.fetchLocationForHeroWith(id: "D13A40E5-4418-4223-9CE6-D2F9A28EBE94") { result in
            switch result {
            case .success(let locations):
                print(locations.map({$0.latitude}))
                StoreDataProvider.shared.insert(locations: locations)

            case .failure(let error):
                print(error)
            }
        }
    }
}
