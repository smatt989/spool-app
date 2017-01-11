//
//  EditWaypointViewController.swift
//  Trax
//
//  Created by Matthew Slotkin on 1/6/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class EditWaypointViewController: UIViewController, UITextFieldDelegate {

    var waypointToEdit: Marker? { didSet { updateUI() } }
    
    private func updateUI() {
        nameTextField?.text = waypointToEdit?.title
        //infoTextField?.text = waypointToEdit?.info
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        nameTextField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listenToTextFields()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopListeningToTextFields()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        preferredContentSize = view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    }
    
    private var ntfObserver: NSObjectProtocol?
    private var itfObserver: NSObjectProtocol?
    
    private func listenToTextFields() {
        let center = NotificationCenter.default
        let queue = OperationQueue.main
        
        ntfObserver = center.addObserver(
            forName: Notification.Name.UITextFieldTextDidChange,
            object: nameTextField,
            queue: queue){ notification in
                if let waypoint = self.waypointToEdit {
                    waypoint.title = self.nameTextField.text
                }
        }
        
//        itfObserver = center.addObserver(
//            forName: Notification.Name.UITextFieldTextDidChange,
//            object: infoTextField,
//            queue: queue){ notification in
//                if let waypoint = self.waypointToEdit {
//                    waypoint.info = self.infoTextField.text
//                }
//        }

    }
    
    private func stopListeningToTextFields() {
        if let observer = ntfObserver {
            NotificationCenter.default.removeObserver(observer)
        }
//        if let observer = itfObserver {
//            NotificationCenter.default.removeObserver(observer)
//        }
    }
    
    @IBOutlet weak var nameTextField: UITextField! { didSet { nameTextField.delegate = self } }
    //@IBOutlet weak var infoTextField: UITextField! { didSet { infoTextField.delegate = self } }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
