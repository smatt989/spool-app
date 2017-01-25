//
//  MarkerNameLabel.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/25/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class MarkerNameLabel: UILabel, MarkerUIElement {

    var waypoint: Marker?
    
    let width = 100.0
    let height = 30.0

    func setupLabel(outerFrame: CGRect) {
        self.frame = CGRect(x: (Double(outerFrame.maxX) - width) / 2, y: 200, width: width, height: height)
        self.backgroundColor = UIColor.black
        self.textColor = UIColor.white
        self.text = waypoint?.title
    }
}
