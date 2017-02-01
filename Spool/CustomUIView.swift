//
//  CustomUIView.swift
//  Spool
//
//  Created by Andrew Ckor on 02/02/2017.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class CustomUIView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
            
        }
    }

}
