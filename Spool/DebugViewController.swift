//
//  DebugViewController.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/16/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class DebugViewController: UIViewController {


    @IBOutlet weak var debugLog: UITextView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        debugLog.text = text
    }
    
    var text = "" 

}
