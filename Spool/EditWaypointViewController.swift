//
//  EditWaypointViewController.swift
//  Trax
//
//  Created by Matthew Slotkin on 1/6/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class EditWaypointViewController: UIFormViewController, UITextFieldDelegate {

    var waypointToEdit: Marker? { didSet { updateUI() } }
    
    private func updateUI() {
        nameTextField?.text = waypointToEdit?.title
        guideUserSwitch?.isOn = waypointToEdit?.showDirections ?? true
        showBeaconSwitch?.isOn = waypointToEdit?.showBeaconWithinMeterRange != nil
        showNameSwitch?.isOn = waypointToEdit?.showNameWithinMeterRange != nil
        showNoteSwitch?.isOn = waypointToEdit?.showDescriptionWithinMeterRange != nil
        
        beaconRangeInput?.isEnabled = showBeaconSwitch.isOn
        beaconRangeInput?.text = String(waypointToEdit?.showBeaconWithinMeterRange ?? 15)
        nameRangeInput?.isEnabled = showNameSwitch.isOn
        nameRangeInput?.text = String(waypointToEdit?.showNameWithinMeterRange ?? 15)
        noteRangeInput?.isEnabled = showNoteSwitch.isOn
        noteRangeInput?.text = String(waypointToEdit?.showDescriptionWithinMeterRange ?? 15)
        noteTextInput?.isUserInteractionEnabled = showNoteSwitch.isOn
        noteTextInput?.text = waypointToEdit?.descriptionText ?? "Enter note here..."
        noteTextInput?.isHidden = !showNoteSwitch.isOn
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
    private var beaconInputObserver: NSObjectProtocol?
    private var nameInputObserver: NSObjectProtocol?
    private var noteInputObserver: NSObjectProtocol?
    private var noteTextObserver: NSObjectProtocol?
    
    private func listenToTextFields() {
        let center = NotificationCenter.default
        let queue = OperationQueue.main
        
        ntfObserver = center.addObserver(
            forName: Notification.Name.UITextFieldTextDidChange,
            object: nameTextField,
            queue: queue){ [weak weakself = self] notification in
                if let waypoint = weakself?.waypointToEdit {
                    waypoint.title = weakself?.nameTextField.text
                }
        }
        
        beaconInputObserver = center.addObserver(
            forName: Notification.Name.UITextFieldTextDidChange,
            object: beaconRangeInput,
            queue: queue){ [weak weakself = self] notification in
                if let waypoint = weakself?.waypointToEdit, weakself!.showBeaconSwitch.isOn {
                    waypoint.showBeaconWithinMeterRange = Int(weakself!.beaconRangeInput.text!)
                }
        }
        
        nameInputObserver = center.addObserver(
            forName: Notification.Name.UITextFieldTextDidChange,
            object: nameRangeInput,
            queue: queue){ [weak weakself = self] notification in
                if let waypoint = weakself!.waypointToEdit, weakself!.showNameSwitch.isOn {
                    waypoint.showNameWithinMeterRange = Int(weakself!.nameRangeInput.text!)
                }
        }
        
        noteInputObserver = center.addObserver(
            forName: Notification.Name.UITextFieldTextDidChange,
            object: noteRangeInput,
            queue: queue){ [weak weakself = self] notification in
                if let waypoint = weakself!.waypointToEdit, weakself!.showNoteSwitch.isOn {
                    waypoint.showDescriptionWithinMeterRange = Int(weakself!.noteRangeInput.text!)
                }
        }
        
        noteTextObserver = center.addObserver(
            forName: Notification.Name.UITextViewTextDidChange,
            object: noteTextInput,
            queue: queue){ [weak weakself = self] notification in
                if let waypoint = weakself!.waypointToEdit, weakself!.showNoteSwitch.isOn {
                    waypoint.descriptionText = weakself?.noteTextInput.text
                }
        }

    }
    
    private func stopListeningToTextFields() {
        if let observer = ntfObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        if let observer = beaconInputObserver {
            NotificationCenter.default.removeObserver(observer)
        }

        if let observer = nameInputObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        if let observer = noteInputObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        if let observer = noteTextObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    @IBOutlet weak var nameTextField: UITextField! { didSet { nameTextField.delegate = self } }

    @IBOutlet weak var guideUserSwitch: UISwitch!
    @IBOutlet weak var showBeaconSwitch: UISwitch!
    @IBOutlet weak var showNameSwitch: UISwitch!
    @IBOutlet weak var showNoteSwitch: UISwitch!
    @IBOutlet weak var beaconRangeInput: UITextField!
    @IBOutlet weak var nameRangeInput: UITextField!
    @IBOutlet weak var noteRangeInput: UITextField!
    @IBOutlet weak var noteTextInput: UITextView!
    
    @IBAction func toggleUserSwitch(_ sender: UISwitch) {
        waypointToEdit?.showDirections = sender.isOn
        updateUI()
    }
    
    
    @IBAction func toggleShowBeaconSwitch(_ sender: UISwitch) {
        if sender.isOn {
            if let meterText = beaconRangeInput.text, meterText != "" {
                waypointToEdit?.showBeaconWithinMeterRange = Int(meterText)
            }
        } else {
            waypointToEdit?.showBeaconWithinMeterRange = nil
        }
        updateUI()
    }
    
    @IBAction func toggleShowNameSwitch(_ sender: UISwitch) {
        if sender.isOn {
            if let meterText = nameRangeInput.text, meterText != "" {
                waypointToEdit?.showNameWithinMeterRange = Int(meterText)
            }
        } else {
            waypointToEdit?.showNameWithinMeterRange = nil
        }
        updateUI()
    }
    
    
    @IBAction func toggleShowNoteSwitch(_ sender: UISwitch) {
        if sender.isOn {
            if let meterText = noteRangeInput.text, let noteText = noteTextInput.text, meterText != "", noteText != "" {
                waypointToEdit?.showDescriptionWithinMeterRange = Int(meterText)
                waypointToEdit?.descriptionText = noteText
            }
        } else {
            waypointToEdit?.showDescriptionWithinMeterRange = nil
        }
        updateUI()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
