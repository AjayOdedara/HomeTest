//  MyTakeHomeTest
//
//  Created by Ajay Odedra on 23/03/19.
//  Copyright © 2019 Ajay Odedra. All rights reserved.
//

import CoreData

class CoreDataStack {
  
  static let persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "MyTakeHomeTest")
    container.loadPersistentStores { (_, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    return container
  }()
  
  static var context: NSManagedObjectContext { return persistentContainer.viewContext }
  
  class func saveContext () {
    let context = persistentContainer.viewContext
    
    guard context.hasChanges else {
      return
    }
    
    do {
      try context.save()
    } catch {
      let nserror = error as NSError
      fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
    }
  }
    class func retriveSaveContext () -> [Run] {
        let context = persistentContainer.viewContext
        var locations  = [Run]()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Run")
        do {
            locations = try context.fetch(fetchRequest) as! [Run]
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return locations
        
    }
}
