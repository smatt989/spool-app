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
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.view.backgroundColor = UIColor.clear
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
