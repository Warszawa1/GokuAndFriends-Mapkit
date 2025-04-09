//
//  ApiHeroLocation.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 3/4/25.
//

import Foundation

struct ApiHeroLocation: Codable {
    let id: String
    let longitude: String?
    let latitude: String?
    let date: String?
    let hero: ApiHero?
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case longitude = "logitud"
        case latitude = "latitude"
        case date = "dateShow"
        case hero
    }
    
}

/*
 "dateShow": "2024-10-20T00:00:00Z",
 "longitud": "139.8202084625344",
 "id": "36E934EC-C786-4A8F-9C48-A6989BCA929E",
 "latitud": "35.71867899343361",
 "hero": {
     "id": "D13A40E5-4418-4223-9CE6-D2F9A28EBE94"
 }
 */
