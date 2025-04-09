//
//  ApiHero.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 3/4/25.
//

import Foundation


struct ApiHero: Codable {
    let id: String
    var favorite: Bool?
    let name : String?
    let description: String?
    let photo: String?
}

/*
 {
     "id": "D13A40E5-4418-4223-9CE6-D2F9A28EBE94",
     "favorite": true,
     "name": "Goku",
     "description": "Sobran las presentaciones cuando se habla de Goku. El Saiyan fue enviado al planeta Tierra, pero hay dos versiones sobre el origen del personaje. Según una publicación especial, cuando Goku nació midieron su poder y apenas llegaba a dos unidades, siendo el Saiyan más débil. Aun así se pensaba que le bastaría para conquistar el planeta. Sin embargo, la versión más popular es que Freezer era una amenaza para su planeta natal y antes de que fuera destruido, se envió a Goku en una incubadora para salvarle.",
     "photo": "https://cdn.alfabetajuega.com/alfabetajuega/2020/12/goku1.jpg?width=300"
 }
 */
