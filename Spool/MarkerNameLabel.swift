//
//  MarkerNameLabel.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/25/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class MarkerNameLabel: UILabel, MarkerUIElement {

    let indicatorIcon = #imageLiteral(resourceName: "Toolbar - Note")
    
    let width = 100.0
    let height = 40.0

    func setup(outerFrame: CGRect, waypoint: Marker) {
        self.frame                =   CGRect(x: (Double(outerFrame.maxX) - width) / 2, y: 250, width: width, height: height)
        self.backgroundColor      =   UIColor(red:0.90, green:0.25, blue:0.43, alpha:1.0) // #E53F6D
        self.layer.cornerRadius   =   CGFloat(18.0)
        self.clipsToBounds        =   true
        self.font                 =   UIFont(name: "Nunito-SemiBold", size: 16)!
        self.textAlignment        =   NSTextAlignment.center
        self.textColor            =   UIColor.white
        self.text                 =   waypoint.title
    }
}
