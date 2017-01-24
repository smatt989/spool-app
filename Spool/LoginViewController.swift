//
//  LoginViewController.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/23/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class LoginViewController: UIFormViewController {
    
    var managedObjectContext =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    @IBOutlet weak var usernameInput: UITextField!
    
    @IBOutlet weak var passwordInput: UITextField!
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    @IBAction func signIn(_ sender: UIButton) {
        if let password = passwordInput.text, let username = usernameInput.text {
            User.login(username: username,
                       password: password,
                       managedObjectContext: managedObjectContext!,
                       success: loginSuccess,
                       failure: loginFailure)
        }
    }
    
    private func loginSuccess(user: User) {
        appDelegate.routeGivenAuthentication()
    }
    
    private func loginFailure(error: Error) {
        appDelegate.loginFailure()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

}
