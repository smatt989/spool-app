//
//  AdventureUtilities.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/30/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation
import CoreLocation

class AdventureUtilities {
    
    static func validTitle(title: String?) -> Bool {
        return title != nil && title != ""
    }
    
    static func distanceToString(distance: CLLocationDistance) -> String {
        if distance < 1000 {
            return String(Int(round(distance / 10) * 10)) + "m away"
        } else {
            return String(Int(round(distance / 1000))) + "km away"
        }
    }
    
    static let transformConstant = 1 / 500.0
}
