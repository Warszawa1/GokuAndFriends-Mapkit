//
//  LoginController.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 3/4/25.
//


import UIKit

final class LoginController: UIViewController {
    // MARK: - Properties
    private let viewModel: LoginViewModel
    
    // MARK: - UI Elements
    private let logoImageView = UIImageView()
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Initialization
    init(viewModel: LoginViewModel = LoginViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .loading:
                    self?.showLoading(true)
                case .error(let reason):
                    self?.showLoading(false)
                    self?.showAlert(title: "Error de Login", message: reason)
                    self?.showLoginError()
                case .success:
                    self?.showLoading(false)
                    self?.navigateToHeroesList()
                case .initial:
                    self?.activityIndicator.isHidden = true
                    self?.loginButton.isEnabled = true
                    self?.passwordTextField.isEnabled = true
                }
            }
        }
    }
    
    private func showLoading(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            loginButton.isEnabled = false
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            loginButton.isEnabled = true
        }
    }
    
    private func navigateToHeroesList() {
        let heroesVC = HeroesController()
        navigationController?.pushViewController(heroesVC, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Set background color
        view.backgroundColor = .systemBackground
        
        // Setup logo image view
        logoImageView.image = UIImage(named: "dragonBall")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)
        
        // Setup email text field
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.keyboardType = .emailAddress
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emailTextField)
        
        // Setup password text field
        passwordTextField.placeholder = "Contraseña"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(passwordTextField)
        
        // Setup login button
        loginButton.setTitle("Iniciar Sesión", for: .normal)
        loginButton.backgroundColor = .systemBlue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 8
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        view.addSubview(loginButton)
        
        // Setup activity indicator
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.isHidden = true
        view.addSubview(activityIndicator)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Logo
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 150),
            logoImageView.heightAnchor.constraint(equalToConstant: 150),
            
            // Email field
            emailTextField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 40),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Password field
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Login button
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 40),
            loginButton.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Activity indicator
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20)
        ])
    }
    
    // MARK: - Actions
    @objc private func loginButtonTapped() {
        viewModel.login(username: emailTextField.text, password: passwordTextField.text)
    }
    
    private func showLoginError() {
        // Shake animation for the login form
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        loginButton.layer.add(animation, forKey: "shake")
        
        // Highlight the fields in red
        UIView.animate(withDuration: 0.2, animations: {
            self.emailTextField.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
            self.passwordTextField.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.emailTextField.backgroundColor = .systemBackground
                self.passwordTextField.backgroundColor = .systemBackground
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

//import UIKit
//
//enum LoginState: Equatable {
//    case success
//    case loading
//    case error(reason: String)
//}
//
//class LoginViewModel {
//    let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImtpZCI6InByaXZhdGUifQ.eyJlbWFpbCI6ImlhbnRlbG9AdW9jLmVkdSIsImV4cGlyYXRpb24iOjY0MDkyMjExMjAwLCJpZGVudGlmeSI6IjM2REFFNkRDLTEzQUYtNEM5RS1CRTIyLUM1QzgwRTA1NUVBRiJ9.zQ5ebMCRtMbPjNlHipzzJIDD0sY-4tq4htYNmaAfRJw"
//    private var secureData: SecureDataProtocol
//    
//    init(secureData: SecureDataProtocol = SecureDataProvider()) {
//        self.secureData = secureData
//    }
//    
//    func saveToken() {
//        secureData.setToken(token)
//        
//    }
//}
//
//class LoginController: UIViewController {
//    
//    private var viewModel: LoginViewModel
//    
//    init(viewModel: LoginViewModel = .init()) {
//        self.viewModel = viewModel
//        super.init(nibName: String(describing: LoginController.self), bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
////        let heroes = StoreDataProvider.shared.fetchHeroes(filter: nil)
////        if heroes.isEmpty {
////            testApiHeroes()
////        } else {
////            debugPrint("Heroes from Data Base")
////            print(heroes.map({$0.name}))
////            testApiLocations()
////        }
//    }
//    
//    @IBAction func loginTapped(_ sender: Any) {
//        viewModel.saveToken()
//        let heroesVC = HeroesController()
//        navigationController?.pushViewController(heroesVC, animated: true)
//    }
//    
//    
//    func testApiHeroes() {
//        let apiProvider = ApiProvider()
//        
//        apiProvider.fetchHeroes { result in
//            switch result {
//            case .success(let heroes):
//                print("Data from Service")
//                print(heroes.map({$0.name}))
//                StoreDataProvider.shared.insert(heroes: heroes)
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
//    
//    
//    func testApiLocations() {
//        let apiProvider = ApiProvider()
//        
//        apiProvider.fetchLocationForHeroWith(id: "D13A40E5-4418-4223-9CE6-D2F9A28EBE94") { result in
//            switch result {
//            case .success(let locations):
//                print(locations.map({$0.latitude}))
//                StoreDataProvider.shared.insert(locations: locations)
//
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
//}
