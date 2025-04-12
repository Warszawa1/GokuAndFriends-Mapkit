//
//  HeroDetailController.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 9/4/25.
//

import UIKit
import MapKit
import CoreLocation
import Kingfisher

class HeroDetailController: UIViewController, MKMapViewDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - UI Elements (Programmatic)
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var nameLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var transformationsLabel: UILabel!
    private var transformationsCollectionView: UICollectionView!
    
    // MARK: - Properties
    private var viewModel: HeroDetailViewModel
    private var locationManager: CLLocationManager = .init()
    private var transformations: [Transformation] = []
    
    // MARK: - Initialization
    init(viewModel: HeroDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: HeroDetailController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProgrammaticUI()
        configurateView()
        listenChangesInViewModel()
        checkLocationAuthorizationStatus()
        viewModel.loadData()
    }
    
    // MARK: - UI Setup
    private func setupProgrammaticUI() {
        // Create a scroll view container
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Content view for scroll view
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Create name label
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 0
        contentView.addSubview(nameLabel)
        
        // Create description label
        descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 18)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        contentView.addSubview(descriptionLabel)
        
        // Move the map view from the main view to the content view
        mapView.removeFromSuperview()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mapView)
        
        // Create transformations label
        transformationsLabel = UILabel()
        transformationsLabel.translatesAutoresizingMaskIntoConstraints = false
        transformationsLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        transformationsLabel.text = "Transformaciones"
        contentView.addSubview(transformationsLabel)
        
        // Create a collection view for transformations
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 150)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        transformationsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        transformationsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        transformationsCollectionView.backgroundColor = .clear
        transformationsCollectionView.showsHorizontalScrollIndicator = false
        transformationsCollectionView.delegate = self
        transformationsCollectionView.dataSource = self
        transformationsCollectionView.register(TransformationCell.self, forCellWithReuseIdentifier: "TransformationCell")
        contentView.addSubview(transformationsCollectionView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Map view at the top - full width
            mapView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mapView.heightAnchor.constraint(equalToConstant: 220),
            
            // Description label below map
            descriptionLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Transformations label
            transformationsLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            transformationsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            transformationsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Transformations collection view
            transformationsCollectionView.topAnchor.constraint(equalTo: transformationsLabel.bottomAnchor, constant: 8),
            transformationsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            transformationsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            transformationsCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 150),
            transformationsCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func configurateView() {
        // Configure map
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        // Configure hero details
        title = viewModel.hero.name
        nameLabel.text = viewModel.hero.name
        descriptionLabel.text = viewModel.hero.description
    }
    
    // MARK: - State Management
    func listenChangesInViewModel() {
        viewModel.stateChanged = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .locationsUpdated:
                    self?.addAnnotationsToMap()
                case .transformationsUpdated:
                    self?.updateTransformationsUI()
                case .errorLoadingLocation(error: let error):
                    debugPrint(error.localizedDescription)
                case .errorLoadingTransformations(error: let error):
                    debugPrint(error.localizedDescription)
                }
            }
        }
    }
    
    private func updateTransformationsUI() {
        transformations = viewModel.getTransformations()
        
        // If there are no transformations, show a message
        if transformations.isEmpty {
            // Hide collection view
            transformationsCollectionView.isHidden = true
            
            // Create and show "No transformations" label
            let noTransformationsLabel = UILabel()
            noTransformationsLabel.translatesAutoresizingMaskIntoConstraints = false
            noTransformationsLabel.text = "No tiene transformaciones"
            noTransformationsLabel.textAlignment = .center
            noTransformationsLabel.textColor = .secondaryLabel
            noTransformationsLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            contentView.addSubview(noTransformationsLabel)
            
            NSLayoutConstraint.activate([
                noTransformationsLabel.topAnchor.constraint(equalTo: transformationsLabel.bottomAnchor, constant: 16),
                noTransformationsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                noTransformationsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                noTransformationsLabel.heightAnchor.constraint(equalToConstant: 44),
                noTransformationsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
            ])
        } else {
            // Show collection view and reload data
            transformationsCollectionView.isHidden = false
            transformationsCollectionView.reloadData()
        }
    }
    
    // MARK: - Show Transformation Detail
    private func showTransformationDetail(transformation: Transformation) {
        let detailVC = UIViewController()
        detailVC.view.backgroundColor = .systemBackground
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        detailVC.view.addSubview(scrollView)
        
        // Create content view for the scroll view
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        
        // Create image view
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        
        if let photoURLString = transformation.photo, let photoURL = URL(string: photoURLString) {
            imageView.kf.setImage(
                with: photoURL,
                placeholder: UIImage(systemName: "person.fill"),
                options: [.transition(.fade(0.2)), .cacheOriginalImage]
            )
        } else {
            imageView.image = UIImage(systemName: "person.fill")
        }
        
        // Create title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.text = transformation.name
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        // Create description label
        let descLabel = UILabel()
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.font = UIFont.systemFont(ofSize: 16)
        descLabel.text = transformation.description
        descLabel.numberOfLines = 0
        descLabel.textAlignment = .center
        contentView.addSubview(descLabel)
        
        // Add to view
        detailVC.view.addSubview(imageView)
        detailVC.view.addSubview(titleLabel)
        detailVC.view.addSubview(descLabel)
        
        // Add close button
        let closeButton = UIButton(type: .system)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("Cerrar", for: .normal)
        closeButton.tintColor = .systemRed
        closeButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
        contentView.addSubview(closeButton)
    
        // Setup scroll view constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: detailVC.view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: detailVC.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: detailVC.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: detailVC.view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.7),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            closeButton.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 20),
            closeButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            closeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        // Present the modal
        detailVC.modalPresentationStyle = .pageSheet
        present(detailVC, animated: true)
    }
    
    @objc private func dismissModal() {
        dismiss(animated: true)
    }
    
    // MARK: - Map Methods
    func addAnnotationsToMap() {
        // Clear existing annotations
        let annotations = mapView.annotations
        if !annotations.isEmpty {
            mapView.removeAnnotations(annotations)
        }
        
        // Get hero annotations
        let heroAnnotations = viewModel.getHeroLocations()
        
        // Add annotations to map
        mapView.addAnnotations(heroAnnotations)
        
        if heroAnnotations.isEmpty {
            print("⚠️ No valid annotations to display")
            
            // Set default region (example: Tokyo)
            let defaultLocation = CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917)
            mapView.setRegion(MKCoordinateRegion(center: defaultLocation,
                                                latitudinalMeters: 700_000,
                                                longitudinalMeters: 700_000), animated: true)
            
            // Optionally show an alert to the user
            let alert = UIAlertController(
                title: "Location Unavailable",
                message: "No location data available for this hero.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else {
            print("✅ Displaying \(heroAnnotations.count) annotations")
            
            // Center map on the first annotation
            if let annotation = heroAnnotations.first {
                mapView.setRegion(MKCoordinateRegion(
                    center: annotation.coordinate,
                    latitudinalMeters: 700_000,
                    longitudinalMeters: 700_000
                ), animated: true)
            }
        }
    }
    
    private func checkLocationAuthorizationStatus() {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            mapView.showsUserLocation = false
        case .authorizedAlways, .authorizedWhenInUse:
            if #available(iOS 17.0, *) {
                mapView.showsUserTrackingButton = true
            } else {
                // Add our custom tracking button for iOS 16
                addCustomUserTrackingButton()
            }
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    private func addCustomUserTrackingButton() {
        let trackingButton = UIButton(type: .system)
        trackingButton.setImage(UIImage(systemName: "location"), for: .normal)
        trackingButton.backgroundColor = .white
        trackingButton.layer.cornerRadius = 20
        trackingButton.tintColor = .blue
        trackingButton.layer.shadowColor = UIColor.black.cgColor
        trackingButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        trackingButton.layer.shadowRadius = 2
        trackingButton.layer.shadowOpacity = 0.3
        trackingButton.addTarget(self, action: #selector(toggleUserTracking), for: .touchUpInside)
        
        // Add button to view hierarchy
        trackingButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackingButton)
        
        NSLayoutConstraint.activate([
            trackingButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -16),
            trackingButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -16),
            trackingButton.widthAnchor.constraint(equalToConstant: 40),
            trackingButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func toggleUserTracking() {
        if mapView.userTrackingMode == .none {
            mapView.setUserTrackingMode(.follow, animated: true)
        } else {
            mapView.setUserTrackingMode(.none, animated: true)
        }
    }
}

// MARK: - Collection View Delegate & Data Source
extension HeroDetailController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return transformations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TransformationCell", for: indexPath) as! TransformationCell
        let transformation = transformations[indexPath.item]
        cell.configure(with: transformation)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let transformation = transformations[indexPath.item]
        showTransformationDetail(transformation: transformation)
    }
}

// MARK: - Transformation Cell
class TransformationCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Image view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray5
        contentView.addSubview(imageView)
        
        // Label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2
        contentView.addSubview(nameLabel)
        
        // Constraints
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.7),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with transformation: Transformation) {
        nameLabel.text = transformation.name
        
        if let photoURLString = transformation.photo, let photoURL = URL(string: photoURLString) {
            imageView.kf.setImage(
                with: photoURL,
                placeholder: UIImage(systemName: "person.fill"),
                options: [.transition(.fade(0.2)), .cacheOriginalImage]
            )
        } else {
            imageView.image = UIImage(systemName: "person.fill")
        }
    }
}
