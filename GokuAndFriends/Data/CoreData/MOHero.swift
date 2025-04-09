//
//  MOHeroLocation+CoreDataClass.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 3/4/25.
//
//

import Foundation
import CoreData

@objc(MOHero)
public class MOHero: NSManagedObject {

}

extension MOHero {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MOHero> {
        return NSFetchRequest<MOHero>(entityName: "Hero")
    }

    @NSManaged public var identifier: String?
    @NSManaged public var name: String?
    @NSManaged public var info: String?
    @NSManaged public var photo: String?
    @NSManaged public var favorite: Bool
    @NSManaged public var locations: Set<MOHeroLocation>?

}

// MARK: Generated accessors for locations
extension MOHero {

    @objc(addLocationsObject:)
    @NSManaged public func addToLocations(_ value: MOHeroLocation)

    @objc(removeLocationsObject:)
    @NSManaged public func removeFromLocations(_ value: MOHeroLocation)

    @objc(addLocations:)
    @NSManaged public func addToLocations(_ values: Set<MOHeroLocation>)

    @objc(removeLocations:)
    @NSManaged public func removeFromLocations(_ values: Set<MOHeroLocation>)

}

extension MOHero : Identifiable {

}

extension MOHero {
    // Mapper para crear un objeto Hero de Domain a partir de MOHero
    func mapToHero() -> Hero {
        Hero(id: self.identifier ?? "",
             favorite: self.favorite,
             name: self.name,
             description: self.info,
             photo: self.photo)
    }
}

