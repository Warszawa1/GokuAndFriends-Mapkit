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
    
    typealias Datasource = UICollectionViewDiffableDataSource<HeroesSections, Hero>
    typealias CellRegistration = UICollectionView.CellRegistration< HeroCell, Hero>

    @IBOutlet weak var collectionView: UICollectionView!
    
    
    private var viewModel: HeroesViewModel
    private var datasource: Datasource?
    
    init( viewModel: HeroesViewModel = HeroesViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: HeroesController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listenStatesChangesInViewModel()
        configureCollectionView()
        viewModel.loadData()
    }

    func configureCollectionView() {
        collectionView.delegate = self
    
        
        let nib = UINib(nibName: HeroCell.identifier, bundle: nil)
        let cellRegistration = CellRegistration(cellNib: nib) { cell, IndexPath, hero in
            // configurar celda
            cell.configureWith(hero: hero)
        }
        
        datasource = Datasource(collectionView: collectionView, cellProvider: { collectionView, indexPath, hero in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration , for: indexPath, item: hero)
            
        })
        
    }
    
    func listenStatesChangesInViewModel() {
        
        viewModel.stateChaged = { [weak self] state in
            switch state {
            case .dataUpdated:
                // Mostrar los heroes
                var snapshot = NSDiffableDataSourceSnapshot<HeroesSections, Hero>()
                snapshot.appendSections([.main])
                snapshot.appendItems(self?.viewModel.fetchHeroes() ?? [], toSection: .main)
                self?.datasource?.applySnapshotUsingReloadData(snapshot)
                
            case .errorLoadingHeroes(error: let error):
                print(error)
            }
        }
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        viewModel.performLogout()
        navigationController?.popToRootViewController(animated: true)
    }
    
}

extension HeroesController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 80.0)
    }
    
}
