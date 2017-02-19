//
//  AdventuresNavigationController.swift
//  Spool
//
//  Created by Andrew Ckor on 25/01/2017.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class AdventuresNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Style the navbar
        self.navigationBar.tintColor = UIColor(red:0.40, green:0.45, blue:0.90, alpha:1.0) //#6772e5
        self.navigationBar.titleTextAttributes = [
            NSFontAttributeName : UIFont(name: "Nunito-Bold", size: 19)! ,
            NSForegroundColorAttributeName : UIColor.white ] //#32325d
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([
            NSFontAttributeName : UIFont(name: "Nunito-Bold", size: 19)! ,
            NSForegroundColorAttributeName : UIColor(red:0.20, green:0.20, blue:0.36, alpha:1.0) ], for: UIControlState.normal)
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([
            NSFontAttributeName : UIFont(name: "Nunito-Bold", size: 19)! ,
            NSForegroundColorAttributeName : UIColor(red:0.20, green:0.20, blue:0.36, alpha:1.0) ], for: UIControlState.normal)
    }

}
