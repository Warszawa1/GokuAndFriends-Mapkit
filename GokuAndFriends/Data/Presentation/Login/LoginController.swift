//
//  LoginController.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 3/4/25.
//


import UIKit

class LoginController: UIViewController {
    // MARK: - UI Elements
    private let logoImageView = UIImageView()
    private let usernameTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Properties
    private var viewModel: LoginViewModel
    
    // MARK: - Initialization
    init(viewModel: LoginViewModel = .init()) {
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
        setupBindings()
        setupKeyboardHandling()
        
        // Hide back button
        navigationItem.hidesBackButton = true
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Set background to light
        view.backgroundColor = .white
        
        // Add a scroll view
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Add a content view inside scroll view
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Set up scroll view constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Setup logo image view
        logoImageView.image = UIImage(named: "bolaDragon") // Make sure this exists in your assets
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(logoImageView)
        
        // Setup username text field - light theme
        usernameTextField.placeholder = "Usuario"
        usernameTextField.borderStyle = .roundedRect
        usernameTextField.backgroundColor = UIColor.systemGray6
        usernameTextField.textColor = .black
        usernameTextField.autocapitalizationType = .none
        usernameTextField.autocorrectionType = .no
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(usernameTextField)
        
        // Setup password text field - light theme
        passwordTextField.placeholder = "Contraseña"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.backgroundColor = UIColor.systemGray6
        passwordTextField.textColor = .black
        passwordTextField.isSecureTextEntry = true
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(passwordTextField)
        
        // Setup login button - light theme
        loginButton.setTitle("Continuar", for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        loginButton.backgroundColor = .none
        loginButton.layer.cornerRadius = 8
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        contentView.addSubview(loginButton)
        
        // Setup activity indicator - light theme
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .gray
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.isHidden = true
        contentView.addSubview(activityIndicator)
        
        // Layout constraints - position elements higher on screen
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 80), // Higher position
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),
            
            usernameTextField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            usernameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            usernameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 10),
            passwordTextField.leadingAnchor.constraint(equalTo: usernameTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: usernameTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            loginButton.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            // Make content view taller to allow scrolling when keyboard appears
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor)
        ])
    }
    
    // MARK: - Keyboard Handling
    private func setupKeyboardHandling() {
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if let scrollView = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
                // Add inset to allow scrolling when keyboard is shown
                scrollView.contentInset.bottom = keyboardSize.height
                scrollView.verticalScrollIndicatorInsets.bottom = keyboardSize.height
                
                // Scroll to the active text field
                if let activeField = [usernameTextField, passwordTextField].first(where: { $0.isFirstResponder }) {
                    let rect = activeField.convert(activeField.bounds, to: scrollView)
                    scrollView.scrollRectToVisible(rect.insetBy(dx: 0, dy: -80), animated: true)
                }
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        if let scrollView = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
            // Reset insets when keyboard is hidden
            scrollView.contentInset.bottom = 0
            scrollView.verticalScrollIndicatorInsets.bottom = 0
        }
    }
    
    // MARK: - Cleanup
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Bindings
    private func setupBindings() {
        viewModel.onStateChanged = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .initial:
                    self?.activityIndicator.isHidden = true
                    self?.loginButton.isEnabled = true
                    self?.usernameTextField.isEnabled = true
                    self?.passwordTextField.isEnabled = true
                    
                case .loading:
                    self?.activityIndicator.isHidden = false
                    self?.activityIndicator.startAnimating()
                    self?.loginButton.isEnabled = false
                    self?.usernameTextField.isEnabled = false
                    self?.passwordTextField.isEnabled = false
                    
                case .success:
                    self?.activityIndicator.isHidden = true
                    self?.activityIndicator.stopAnimating()
                    self?.navigateToHeroes()
                    
                case .error(let reason):
                    self?.activityIndicator.isHidden = true
                    self?.activityIndicator.stopAnimating()
                    self?.loginButton.isEnabled = true
                    self?.usernameTextField.isEnabled = true
                    self?.passwordTextField.isEnabled = true
                    self?.showError(message: reason)
                    self?.showLoginError()
                }
            }
        }
    }
    
    // MARK: - Actions
    @objc func loginTapped(_ sender: Any) {
        viewModel.login(username: usernameTextField.text, password: passwordTextField.text)
    }
    
    // MARK: - Navigation
    private func navigateToHeroes() {
        let heroesVC = HeroesController()
        navigationController?.pushViewController(heroesVC, animated: true)
    }
    
    // MARK: - Helper Methods
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error de Login", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showLoginError() {
        // Subtle shake animation for the login form
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        loginButton.layer.add(animation, forKey: "shake")
        
        // Briefly highlights the fields in red for light theme
        UIView.animate(withDuration: 0.2, animations: {
            self.usernameTextField.backgroundColor = UIColor.red.withAlphaComponent(0.2)
            self.passwordTextField.backgroundColor = UIColor.red.withAlphaComponent(0.2)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.usernameTextField.backgroundColor = UIColor.systemGray6
                self.passwordTextField.backgroundColor = UIColor.systemGray6
            }
        }
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
