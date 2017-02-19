//
//  TransparentUINavigationController.swift
//  Spool
//
//  Created by Andrew Ckor on 24/01/2017.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class TransparentUINavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navBarTransparent(controller: self)
    }
    
    public func navBarTransparent (controller: UINavigationController) {
        controller.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        controller.navigationBar.shadowImage = UIImage()
        controller.navigationBar.isTranslucent = true
        controller.navigationBar.tintColor = UIColor.white //#6772e5
        controller.view.backgroundColor = UIColor.clear
    }
    
    public func navBarDefault (controller: UINavigationController) {
        controller.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        controller.navigationBar.shadowImage = nil
        controller.navigationBar.isTranslucent = false
        controller.navigationBar.tintColor = UIColor(red:0.40, green:0.45, blue:0.90, alpha:1.0) //#6772e5
        controller.view.backgroundColor = nil
    }
    
}
