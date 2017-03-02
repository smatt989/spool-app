//
//  Beacon.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/25/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class Beacon: UIImageView, MarkerUIElement {

    var waypoint: Marker?
    
    let indicatorIcon = #imageLiteral(resourceName: "Toolbar - Beacon")
    let indicatorSize: CGFloat = 40.0
    
    var indicator = CustomUIView()
    
    func setupIndicator(frame: CGRect) {
        indicator.frame = CGRect(x: (frame.width - indicatorSize) / 2, y: (frame.height - indicatorSize / 2), width: indicatorSize, height: indicatorSize)
        indicator.cornerRadius = indicatorSize / 2
        indicator.backgroundColor = UIColor(patternImage: indicatorIcon)
        indicator.backgroundColor = UIColor(red:0.90, green:0.25, blue:0.43, alpha:1.0) // #E53F6D
        let imageView = UIImageView(image: indicatorIcon)
        imageView.frame = CGRect(x: (indicatorSize - indicatorIcon.size.width) / 2, y: (indicatorSize - indicatorIcon.size.height) / 2, width: indicatorIcon.size.width, height: indicatorIcon.size.height)
        indicator.tintColor = UIColor.white
        indicator.insertSubview(imageView, at: 0)
        
        indicator.layer.shouldRasterize = true
        indicator.isHidden = true
    }
    
    func setupBeacon(frame: CGRect) {
        let imageWidth:CGFloat    =   75.0
        let imageHeight:CGFloat   =   80.0
        
        self.frame = CGRect(x: (frame.width - imageWidth) / 2, y: (frame.height - imageHeight) / 2, width: imageWidth, height: imageHeight)
        
        self.image = #imageLiteral(resourceName: "star")
        self.layer.shouldRasterize = true
    }
}
