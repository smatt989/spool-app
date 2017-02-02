//
//  ToolbarButton.swift
//  Spool
//
//  Created by Matthew Slotkin on 2/1/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class ToolbarButton: UIButton {

    var isFocus = false {
        didSet {
            if isFocus {
                layer.borderWidth = 2
                layer.borderColor = UIColor.blue.cgColor
            } else {
                layer.borderWidth = 0
            }
        }
    }
    
    var isOn = false {
        didSet {
            if isOn {
                layer.backgroundColor = UIColor.white.cgColor
            } else {
                layer.backgroundColor = UIColor.lightGray.cgColor
                isFocus = false
            }
        }
    }

}
