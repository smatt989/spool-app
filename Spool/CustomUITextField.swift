//
//  CustomUITextField.swift
//  Spool
//
//  Created by Andrew Ckor on 02/02/2017.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit
@IBDesignable

class CustomUITextField: UITextField {
    
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
    
    @IBInspectable var paddingSide: CGFloat = 0 {
        didSet {
            UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(0, paddingSide, 0, paddingSide))
        }
    }
    
    //override func textRect(forBounds bounds: CGRect) -> CGRect {
      //  return UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(0, 10, 0, 10))
 //   }
    
}
