//
//  HeroDetailController.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 9/4/25.
//

import UIKit
import MapKit
import CoreLocation



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
        // 3d view
//        mapView.pitchButtonVisibility = .visible
        mapView.showsUserLocation = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurateView()
        listenChangesInViewModel()
        checkLocationAuthorizationStatus()
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
