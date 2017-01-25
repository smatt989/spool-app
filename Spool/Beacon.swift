//
//  Beacon.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/25/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class Beacon: UIView, MarkerUIElement {

    var waypoint: Marker?
    
    let starView = UIImageView(image: #imageLiteral(resourceName: "star"))
    
    func setupBeacon(frame: CGRect) {
        self.frame = frame
        
        let imageWidth = frame.width / 3
        let imageRatio = imageWidth / starView.frame.width
        let imageHeight = starView.frame.height * imageRatio
        
        starView.frame = CGRect(x: (frame.width - imageWidth) / 2, y: (frame.height - imageHeight) / 2, width: imageWidth, height: imageHeight)
        
        
        starView.layer.shouldRasterize = true
        
        self.addSubview(starView)
    }
}
