//
//  AdventureProgress.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/27/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation

struct AdventureProgress {
    let adventureId: Int
    let step: Int
    var finished: Bool = false
    var updated: NSDate = NSDate()
}
