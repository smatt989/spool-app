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
    
    init(username: String) {
        self.username = username
    }
}

struct UserCreate {
    var username: String
    var email: String
    var password: String
}
