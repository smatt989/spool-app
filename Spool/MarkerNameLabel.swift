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
    
    let indicatorIcon = #imageLiteral(resourceName: "Toolbar - Note")
    let indicatorSize: CGFloat = 40.0
    
    let indicator = CustomUIView()
    
    let width = 100.0
    let height = 40.0
    
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

    func setupLabel(outerFrame: CGRect) {
        self.frame                =   CGRect(x: (Double(outerFrame.maxX) - width) / 2, y: 250, width: width, height: height)
        self.backgroundColor      =   UIColor(red:0.90, green:0.25, blue:0.43, alpha:1.0) // #E53F6D
        self.layer.cornerRadius   =   CGFloat(18.0)
        self.clipsToBounds        =   true
        self.font                 =   UIFont(name: "Nunito-SemiBold", size: 16)!
        self.textAlignment        =   NSTextAlignment.center
        self.textColor            =   UIColor.white
        self.text                 =   waypoint?.title
    }
}
