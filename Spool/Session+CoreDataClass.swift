//
//  Session+CoreDataClass.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/22/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation
import CoreData


public class Session: NSManagedObject {

    
    class func getCurrentSession(managedObjectContext: NSManagedObjectContext) -> String? {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Session")
        request.predicate = NSPredicate(format: "TRUEPREDICATE", [])
        
        return ((try? managedObjectContext.fetch(request))?.last as? Session)?.key
    }
    
    class func setSessionKey(key: String, managedObjectContext: NSManagedObjectContext) -> String {
        removeSessionKey(managedObjectContext: managedObjectContext)
        let session = NSEntityDescription.insertNewObject(forEntityName: "Session", into: managedObjectContext) as! Session
        session.key = key
        try? managedObjectContext.save()
        return session.key!
    }
    
    class func removeSessionKey(managedObjectContext: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Session")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedObjectContext.execute(deleteRequest)
            try? managedObjectContext.save()
        } catch let error as NSError {
            print(error)
        }
    }
}
