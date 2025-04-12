//
//  HeroesController.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 6/4/25.
//

import UIKit

enum HeroesSections {
    case main
}

class HeroesController: UIViewController {
    
    // MARK: - UI Components
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()
    
    // MARK: - Properties
    typealias Datasource = UICollectionViewDiffableDataSource<HeroesSections, Hero>
    typealias CellRegistration = UICollectionView.CellRegistration<HeroCell, Hero>
    
    private var viewModel: HeroesViewModel
    private var datasource: Datasource?
    
    // MARK: - Initialization
    init(viewModel: HeroesViewModel = HeroesViewModel()) {
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
        setupNavigationBar()
        configureCollectionView()
        listenStatesChangesInViewModel()
        viewModel.loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionViewLayout() // Update layout after view is laid out
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add collectionView to view hierarchy
        view.addSubview(collectionView)
        
        // Set constraints
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        title = "Heroes"
        
        navigationItem.hidesBackButton = true
        
        // Create a logout button with a system icon
        let logoutButton = UIBarButtonItem(
            image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )
        logoutButton.tintColor = .systemRed
        
        
        // Set it as the right bar button item
        navigationItem.rightBarButtonItem = logoutButton
    }
    
    func configureCollectionView() {
        // Create a grid layout with 2 columns
        let layout = UICollectionViewFlowLayout()
        
        // Set reasonable defaults initially (will be updated in viewWillLayoutSubviews)
        layout.itemSize = CGSize(width: 100, height: 100) // Safe default
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        // Apply the layout
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        
        // Register cell
        let cellRegistration = UICollectionView.CellRegistration<HeroCell, Hero> { cell, indexPath, hero in
            cell.configureWith(hero: hero)
        }
        
        datasource = Datasource(collectionView: collectionView, cellProvider: { collectionView, indexPath, hero in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: hero)
        })
    }
    
    private func updateCollectionViewLayout() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        // Get current width and make sure it's valid
        let availableWidth = collectionView.bounds.width
        guard availableWidth > 0 else { return } // Skip if width is zero or negative
        
        // Calculate item size based on current screen width
        let spacing: CGFloat = 8
        let numberOfColumns: CGFloat = availableWidth > 500 ? 3 : 2 // Use 3 columns for wider screens
        
        // Calculate width ensuring it's positive
        let itemWidth = max(50, (availableWidth - spacing * (numberOfColumns - 1) - 16) / numberOfColumns)
        
        // Update the item size with a safe value
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        // Invalidate layout to force recalculation
        layout.invalidateLayout()
    }

    func listenStatesChangesInViewModel() {
        viewModel.stateChaged = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .dataUpdated:
                    // Mostrar los heroes
                    var snapshot = NSDiffableDataSourceSnapshot<HeroesSections, Hero>()
                    snapshot.appendSections([.main])
                    snapshot.appendItems(self?.viewModel.fetchHeroes() ?? [], toSection: .main)
                    self?.datasource?.apply(snapshot, animatingDifferences: true)
                    
                case .errorLoadingHeroes(error: let error):
                    print(error)
                    self?.showErrorAlert(message: "Error loading heroes: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Helper method to show errors
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc func logoutTapped(_ sender: Any) {
        viewModel.performLogout()
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - UICollectionViewDelegate
extension HeroesController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let hero = viewModel.heroWith(index: indexPath.row) else {
            return
        }
        let viewModel = HeroDetailViewModel(hero: hero)
        let heroDetail = HeroDetailController(viewModel: viewModel)
        navigationController?.pushViewController(heroDetail, animated: true)
    }

    
    // Ensure 2 columns
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = collectionView.bounds.width
        let spacing: CGFloat = 8
        let numberOfColumns: CGFloat = 2
        let itemWidth = (screenWidth - spacing * (numberOfColumns - 1) - 16) / numberOfColumns
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
}

 
// TODO Presentacion modal del mapa
// present(heroDetail, animated: true)


