//
//  GeoARElement.swift
//  Spool
//
//  Created by Matthew Slotkin on 3/2/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit
import CoreLocation

class GeoARElement {

    var waypoint: Marker?
    
    var uiElement: MarkerUIElement?
    var indicatorSize: CGFloat? = 40
    
    let indicator = CustomUIView()
    
    func setup(view: UIView){
        if waypoint != nil {
            uiElement?.setup(outerFrame: view.frame, waypoint: waypoint!)
            uiElement?.layer.isHidden = true
            setupIndicator(frame: view.frame)
            
            view.insertSubview(uiElement as! UIView, at: 2)
            view.insertSubview(indicator, at: 2)            
        }
    }
    
    func rotate(rotation: Translation2D, distance: CLLocationDistance, view: UIView){
        var transform = CATransform3DIdentity
        transform.m34 = CGFloat(AdventureUtilities.transformConstant)
        
        if rotation.zPosition > 0 {
            uiElement!.layer.isHidden = false
            let translate = CATransform3DTranslate(transform, 0, -(CGFloat)(scaleOffset(dist: distance)), 0)
            let translation3d = CATransform3DMakeTranslation(CGFloat(rotation.x), CGFloat(rotation.y), 0)
            let rotation3d = CATransform3DRotate(transform, CGFloat(rotation.rotation), 0, 0, 1)
            let positionTransform = CATransform3DConcat(CATransform3DConcat(translate, translation3d), rotation3d)
            let scalar = CATransform3DScale(transform, CGFloat(scaleSize(dist: distance)), CGFloat(scaleSize(dist: distance)), 1)
            uiElement!.layer.transform = CATransform3DConcat(positionTransform, scalar)
            uiElement!.layer.zPosition = CGFloat(1000000000.0 - (distance))
            
            moveIndicator(view: view)
        } else {
            uiElement!.layer.isHidden = true
            indicator.isHidden = true
        }
    }
    
    private func inFrame(_ element: MarkerUIElement, view: UIView) -> Bool {
        return element.layer.frame.maxX < view.frame.maxX && element.layer.frame.minX > view.frame.minX && element.layer.frame.maxY < view.frame.maxY && element.layer.frame.minY > view.frame.minY
    }
    
    private let indicatorBuffer: CGFloat = 10
    
    private func moveIndicator(view: UIView) {
        if uiElement != nil && indicatorSize != nil {
            if !inFrame(uiElement!, view: view) {
                var xPosition = uiElement!.layer.frame.minX + (uiElement!.layer.frame.maxX - uiElement!.layer.frame.minX ) / 2 - indicatorSize! / 2
                var yPosition = uiElement!.layer.frame.minY + (uiElement!.layer.frame.maxY - uiElement!.layer.frame.minY) / 2 - indicatorSize! / 2
                
                if uiElement!.layer.frame.minX < view.frame.minX {
                    xPosition = view.frame.minX + indicatorBuffer
                } else if uiElement!.layer.frame.maxX > view.frame.maxX {
                    xPosition = view.frame.maxX - indicatorSize! - indicatorBuffer
                }
                if uiElement!.layer.frame.minY < view.frame.minY {
                    yPosition = view.frame.minY + indicatorBuffer
                } else if uiElement!.layer.frame.maxY > view.frame.maxY {
                    yPosition = view.frame.maxY - indicatorSize! - indicatorBuffer
                }
                
                indicator.frame = CGRect(x: xPosition, y: yPosition, width: indicatorSize!, height: indicatorSize!)
                indicator.isHidden = false
            } else {
                indicator.isHidden = true
            }
        }
    }
    
    private let minScale = 0.5
    
    private func scaleSize(dist: CLLocationDistance) -> Double{
        return 1 / (dist / 100.0 + 1) + minScale
    }
    
    private func scaleOffset(dist: CLLocationDistance) -> Double {
        return sqrt(dist)
    }
    
    private func setupIndicator(frame: CGRect) {
        if uiElement != nil && indicatorSize != nil {
            indicator.frame = CGRect(x: (frame.width - indicatorSize!) / 2, y: (frame.height - indicatorSize! / 2), width: indicatorSize!, height: indicatorSize!)
            indicator.cornerRadius = indicatorSize! / 2
            indicator.backgroundColor = UIColor(patternImage: uiElement!.indicatorIcon)
            indicator.backgroundColor = UIColor(red:0.90, green:0.25, blue:0.43, alpha:1.0) // #E53F6D
            let imageView = UIImageView(image: uiElement!.indicatorIcon)
            imageView.frame = CGRect(x: (indicatorSize! - uiElement!.indicatorIcon.size.width) / 2, y: (indicatorSize! - uiElement!.indicatorIcon.size.height) / 2, width: uiElement!.indicatorIcon.size.width, height: uiElement!.indicatorIcon.size.height)
            indicator.tintColor = UIColor.white
            indicator.insertSubview(imageView, at: 0)
            
            indicator.layer.shouldRasterize = true
            indicator.isHidden = true
        }
    }

}
