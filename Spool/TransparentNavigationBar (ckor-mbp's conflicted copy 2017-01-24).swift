//
//  TransparentNavigationBar.swift
//  Spool
//
//  Created by Andrew Ckor on 24/01/2017.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

@IBDesignable
class TransparentNavigationBar: UINavigationBar {
    
    private var shadowImageView: UIImageView?
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 1 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    override var clipsToBounds: Bool = true
    
    @IBInspectable var noShadow: Bool = false {
        didSet {
            self.setBackgroundImage(UIImage(), for: .default)
        }
    }
    
    @IBInspectable var shadowColor: UIColor = UIColor.clear {
        didSet {
            self.layer.shadowColor = shadowColor.cgColor
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = CGSize.zero {
        didSet {
            self.layer.shadowOffset = shadowOffset
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 3 {
        didSet {
            self.layer.shadowRadius = shadowRadius
        }
    }

}
