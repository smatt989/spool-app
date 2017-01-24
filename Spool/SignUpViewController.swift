//
//  SignUpViewController.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/23/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class SignUpViewController: UIFormViewController {


    @IBOutlet weak var usernameInput: UITextField!

    @IBOutlet weak var emailInput: UITextField!
    
    @IBOutlet weak var passwordInput: UITextField!
    
    @IBOutlet weak var alertText: UITextView!

    @IBAction func createAccount(_ sender: UIButton) {
        if let username = usernameInput.text, let email = emailInput.text, let password = passwordInput.text {
            let userCreate = UserCreate(username: username, email: email, password: password)
            if validSignup(userCreate: userCreate){
                User.signUp(newUser: userCreate, success: createAccountSuccess, failure: createAccountFailure)
            } else {
                cleanFormWithAlert(alert: "All fields must be filled in, password must have at least 6 characters")
            }
        }
    }
    
    private func validSignup(userCreate: UserCreate) -> Bool {
        return userCreate.username.characters.count > 2 && userCreate.email.characters.count > 5 && userCreate.password.characters.count > 5
    }
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private func createAccountSuccess(user: User) {
        appDelegate.loginFailure()
    }
    
    private func createAccountFailure(error: Error) {
        cleanFormWithAlert(alert: error.localizedDescription)
    }
    
    private func cleanFormWithAlert(alert: String) {
        alertText.text = alert
        usernameInput.text = ""
        emailInput.text = ""
        passwordInput.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cleanFormWithAlert(alert: "")
    }
    
    
    
}
