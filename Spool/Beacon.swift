//
//  Beacon.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/25/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class Beacon: UIImageView, MarkerUIElement {
    
    let indicatorIcon = #imageLiteral(resourceName: "Toolbar - Beacon")
    
    func setup(outerFrame: CGRect, waypoint: Marker) {
        let imageWidth:CGFloat    =   75.0
        let imageHeight:CGFloat   =   80.0
        
        self.frame = CGRect(x: (outerFrame.width - imageWidth) / 2, y: (outerFrame.height - imageHeight) / 2, width: imageWidth, height: imageHeight)
        
        self.image = #imageLiteral(resourceName: "star")
        self.layer.shouldRasterize = true
    }
}
