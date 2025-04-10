//
//  HeroLocations.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 6/4/25.
//

import Foundation
import MapKit


struct HeroLocation {
    let id: String
    let longitude: String?
    let latitude: String?
    let date: String?
    let hero: Hero?
    
    
    var debugDescription: String {
        return "HeroLocation(id: \(id), lat: \(latitude ?? "nil"), long: \(longitude ?? "nil"), date: \(date ?? "nil"))"
    }

}

extension HeroLocation {
    var coordinate: CLLocationCoordinate2D? {
        
        guard let longitude,
              let latitude,
            let longitudeDouble = Double(longitude),
              let latitudeDouble = Double(latitude) else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: latitudeDouble, longitude: longitudeDouble)
    }
}
