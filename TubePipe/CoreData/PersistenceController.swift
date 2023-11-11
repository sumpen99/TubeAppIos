//
//  PersistentController.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-05.
//

import SwiftUI
import CoreData

enum CoreDataError:Error{
    case SAVE_FAILED(String)
}

final class PersistenceController {
    // A singleton for our entire app to use
    static let shared = PersistenceController()

    // Storage for Core Data
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TubeDataModel")
        container.loadPersistentStores{ description,error in
            if let error = error {
                fatalError("Unable to load persistent store \(error)")
            }
        }
        return container
    }()
    
    private init(){ }
    
    public func saveContext(backgroundContext:NSManagedObjectContext? = nil) throws{
        let context = backgroundContext ?? container.viewContext
        guard context.hasChanges else { throw CoreDataError.SAVE_FAILED("Context has no changes") }
        try context.save()
        
    }
    
    static func saveContext(backgroundContext:NSManagedObjectContext? = nil) throws{
        let context = backgroundContext ?? shared.container.viewContext
        guard context.hasChanges else { throw CoreDataError.SAVE_FAILED("Context has no changes") }
        try context.save()
        
    }
    
    static func deleteAllData(){
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName:"TubeModel")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try shared.container.viewContext.execute(batchDeleteRequest)
        } catch {
            debugLog(object: error.localizedDescription)
        }
        saveChanges()
    }
    
    static func deleteTubeModel(_ tube: TubeModel?){
        guard let tube = tube else { return }
        shared.container.viewContext.delete(tube)
        saveChanges()
    }
    
    static func deleteTubeImage(_ image: TubeImage?){
        guard let image = image else { return }
        shared.container.viewContext.delete(image)
        saveChanges()
    }
    
    static func fetchCountByPredicate(_ predicate:NSPredicate) -> Int {
        var count: Int = 0
        shared.container.viewContext.performAndWait {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName:"TubeModel")
            fetchRequest.predicate = predicate
            fetchRequest.resultType = NSFetchRequestResultType.countResultType

            do {
                count = try shared.container.viewContext.count(for: fetchRequest)
            } catch {
                debugLog(object: "\(error)")
             }

        }
        return count
    }
    
    static func fetchCountWithoutPredicate() -> Int {
        var count: Int = 0
        shared.container.viewContext.performAndWait {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName:"TubeModel")
            fetchRequest.resultType = NSFetchRequestResultType.countResultType
            do {
                count = try shared.container.viewContext.count(for: fetchRequest)
            } catch {
                debugLog(object: "\(error)")
             }
        }
        return count
    }
    
    static func saveChanges(){
        do {
            try saveContext()
        } catch {
            debugLog(object: error.localizedDescription)
        }
    }
    
}
