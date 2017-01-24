//
//  User.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/22/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation

class User {
    var username: String
    var id: Int
    
    init(username: String, id: Int) {
        self.username = username
        self.id = id
    }
}

struct UserCreate {
    var username: String
    var email: String
    var password: String
}
