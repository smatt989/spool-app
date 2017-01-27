//
//  AdventureShareRequest.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/26/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation

struct AdventureShareRequest {
    let adventureId: Int
    let shareWithUserId: Int
    let note: String?
}

struct SharedAdventure {
    let adventure: AdventureHeadline
    let sender: User
    let receiver: User
    let note: String?
}
