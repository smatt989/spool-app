//
//  ToolbarButton.swift
//  Spool
//
//  Created by Matthew Slotkin on 2/1/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class ToolbarButton: RoundedUIButton {
    
    let onColor  = UIColor(red: 0.48, green: 0.54, blue: 0.92, alpha: 1.0).cgColor // #7A89EB
    let offColor = UIColor(red:0.67, green:0.72, blue:0.78, alpha:1.0).cgColor // #ABB8C7
    
    var isFocus = false {
        didSet {
            if isFocus {
                layer.borderWidth = 3.0
                layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
            } else {
                layer.borderWidth = 0.0
            }
        }
    }
    
    var isOn = false {
        didSet {
            if isOn {
                layer.backgroundColor = onColor
            } else {
                layer.backgroundColor = offColor
                isFocus = false
            }
        }
    }

}
