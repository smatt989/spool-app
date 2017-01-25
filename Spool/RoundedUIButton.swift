//
//  RoundedUIButton.swift
//  Spool
//
//  Created by Andrew Ckor on 25/01/2017.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit
@IBDesignable

class RoundedUIButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
