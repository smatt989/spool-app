//
//  Authentication.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/23/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Authentication {
    
    var currentUser: User?
    
    func authenticateSession(context: NSManagedObjectContext, success: @escaping () -> Void, failure: @escaping () -> Void) {
        if Session.getCurrentSession(managedObjectContext: context) != nil {
            User.checkSession(managedObjectContext: context, success: { [weak weakself = self] user in
                weakself?.currentUser = user
                success()
            }, failure: { [weak weakself = self] error in
                weakself?.currentUser = nil
                failure()
            })
        } else {
            currentUser = nil
            failure()
        }
    }
    
}

extension URLRequest {
    
    mutating func authenticate() {
        if let key = Session.getCurrentSession(managedObjectContext: ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext)!) {
            self.addValue(key, forHTTPHeaderField: User.Headers.sessionHeader)
        } else {
            print("UNABLE TO AUTH")
        }
    }
}
