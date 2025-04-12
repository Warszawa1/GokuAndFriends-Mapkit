//
//  StoreDataProvider.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 4/4/25.
//

import Foundation
import CoreData

enum TypePersistence {
    case disk
    case inMemory
}

class StoreDataProvider {
    
    static let shared: StoreDataProvider = .init()
    
#if DEBUG
    static let sharedTesting: StoreDataProvider = .init(persistence: .inMemory)

#endif
    
    let persistentContainer: NSPersistentContainer
    lazy var context: NSManagedObjectContext = {
        let viewContext = self.persistentContainer.viewContext
        // Actualizar objeto con mergeByPropertyObjectTrump para evitar duplicados
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return viewContext
    }()
    
    // como es un singleton el constructor es privado
    private init(persistence: TypePersistence = .disk) {
        // URL.applicationSupportDirectory
        // Nos da el path donde está añijada la BBDD en el dispositivo
        // Se puede acceder al simulador desde finder
        
        self.persistentContainer = NSPersistentContainer(name: "Model")
        if persistence == .inMemory {
            let persistentStore = self.persistentContainer.persistentStoreDescriptions.first
            persistentStore?.url = URL(filePath: "dev/null")
        }
        self.persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Core data couldn't load BBDD from Model \(error)")
            }
        }
    }
    
    func saveContext() {
        context.perform {  // Usar el contextos en el thread donde fue creado
            guard self.context.hasChanges else { return }
            do {
                try self.context.save()
            } catch {
                debugPrint("There was an error saving the context \(error)")
            }
        }
    }
}

extension StoreDataProvider {
    
    // Obtiene los heroes de la BBD aplicando un filtro si se envía
    func fetchHeroes(filter: NSPredicate?, sortAscending: Bool = true ) -> [MOHero] {
        let request = MOHero.fetchRequest()
        // Sorting the data, order ascending or descending
        let sortDescriptor = NSSortDescriptor(keyPath: \MOHero.name, ascending: sortAscending)
        
        // Same but using string
        // NSSortDescriptor(key: "name", ascending: sortAscending)

        request.sortDescriptors = [sortDescriptor]
        request.predicate = filter
        return (try? context.fetch(request)) ?? []
    }
    
    func numHeroes() -> Int {
        return (try? context.count(for: MOHero.fetchRequest())) ?? -1
    }
    
    // Inserta heroes en contexto y persiste en BBDD con saveContext()
    func insert(heroes: [ApiHero]) {
        for hero in heroes {
            let newHero = MOHero(context: context)
            newHero.identifier = hero.id
            newHero.name = hero.name
            newHero.info = hero.description
            newHero.photo = hero.photo
            newHero.favorite = hero.favorite ?? false
        }
        saveContext()
    }
    
    // Inserta localizaciones de heroes en contexto y persiste en BBDD con saveContext()
    func insert(locations: [ApiHeroLocation]) {
        for location in locations {
            let newLocation = MOHeroLocation(context: context)
            newLocation.identifier = location.id
            newLocation.latitude = location.latitude
            newLocation.longitude = location.longitude
            newLocation.date = location.date
            
            if let identifier = location.hero?.id {
                let predicate = NSPredicate(format: "identifier == %@", identifier)
                newLocation.hero = fetchHeroes(filter: predicate).first
            }
        }
        saveContext()
    }
    
    func clearBBDD() {
            // Quitamos los cambios pendientes que haya en el contexto
            context.rollback()
            
            // creamos los procesos batch de borrado, estos procesos se ejecutan  contra el Store, la BBDD  y no en el contexto.
            let deleteHeroes = NSBatchDeleteRequest(fetchRequest: MOHero.fetchRequest())
            let deleteHeroLocations = NSBatchDeleteRequest(fetchRequest: MOHeroLocation.fetchRequest())
            
            for task in [deleteHeroes, deleteHeroLocations] {
                do {
                    try context.execute(task)
                } catch {
                    debugPrint("There was an error clearing BBDD \(error)")
                }
            }
        }
}
