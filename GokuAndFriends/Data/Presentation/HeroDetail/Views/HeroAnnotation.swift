//
//  HeroAnnotation.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 9/4/25.
//

import Foundation
import MapKit


class HeroAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String? = nil) {
        self.coordinate = coordinate
        self.title = title
        super.init()
    }
}
