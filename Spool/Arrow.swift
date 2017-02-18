//
//  Arrow.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/24/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class Arrow: UIView {
    let arrowView = UIImageView(image: #imageLiteral(resourceName: "blue-arrow"))
    
    func setupArrow(frame: CGRect) {
        //subview = UIView(frame: view.frame)
        self.frame = frame
        
        let imageWidth:CGFloat     =   98.0
        let imageHeight:CGFloat    =   104.0
        
        arrowView.frame = CGRect(x: (frame.width - imageWidth) / 2, y: (frame.height - imageHeight) / 2, width: imageWidth, height: imageHeight)
        
        
        
        self.addSubview(arrowView)
    }
    
}
