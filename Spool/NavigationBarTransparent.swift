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
        controller.view.backgroundColor = UIColor.clear
    }
    
    public func navBarDefault (controller: UINavigationController) {
        controller.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        controller.navigationBar.shadowImage = nil
        controller.navigationBar.isTranslucent = false
        controller.view.backgroundColor = nil
    }
    
}
