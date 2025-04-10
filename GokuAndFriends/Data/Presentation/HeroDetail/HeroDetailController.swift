//
//  HeroDetailController.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 9/4/25.
//

import UIKit
import MapKit

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

class HeroDetailController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    private var viewModel: HeroDetailViewModel
    private var locationManager: CLLocationManager = .init()
    
    init(viewModel: HeroDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: HeroDetailController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configurateView() {
        mapView.delegate = self
//        mapView.pitchButtonVisibility = .visible
        mapView.showsUserLocation = false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurateView()
        listenChangesInViewModel()
//        checkLocationAuthorizationStatus()
        viewModel.loadData()
    }
    
    func listenChangesInViewModel() {
        viewModel.stateChanged = { [weak self] state in
            switch state {
            case .locationsUpdated:
                self?.addAnnotationsToMap()
            case .errorLoadingLocation(error: let error):
                debugPrint(error.localizedDescription)
            }
        }
    }
    
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
}

extension HeroDetailController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        
        guard annotation is HeroAnnotation else {
            return nil
        }
        if  let view = mapView.dequeueReusableAnnotationView(withIdentifier: HeroAnnotationView.identifier) {
            return view
        }
        return HeroAnnotationView(annotation: annotation, reuseIdentifier: HeroAnnotationView.identifier)
    }
}
