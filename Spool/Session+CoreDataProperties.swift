//
//  Session+CoreDataProperties.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/22/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation
import CoreData


extension Session {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Session> {
        return NSFetchRequest<Session>(entityName: "Session");
    }

    @NSManaged public var key: String?

}
