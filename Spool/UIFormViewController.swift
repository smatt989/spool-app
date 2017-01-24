//
//  UIViewFormController.swift
//  Spool
//
//  Created by Andrew Ckor on 24/01/2017.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class UIFormViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Closes keyboard when touch outside
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

}
