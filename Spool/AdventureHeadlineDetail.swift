//
//  AdventureHeadlineDetail.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/27/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation
import CoreLocation

struct AdventureHeadlineDetail {
    let title: String
    let subtitle: String?
    let creator: User
    let id: Int
    let sharers: [User]
    let started: Bool
    let finished: Bool
    let lastUpdate: NSDate?
    let distance: CLLocationDistance
}
