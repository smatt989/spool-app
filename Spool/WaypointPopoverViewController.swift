//
//  WaypointPopoverViewController.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/29/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class WaypointPopoverViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    var waypointToEdit: Marker?
    
    var deleteWaypointHook: ((Marker) -> Void)?
    
    private var defaultRangeValue = 0
    
    private var showBeacon = false
    private var showName = false
    private var showNote = false
    
    private var beaconRange: Int? {
        didSet {
            DispatchQueue.main.async { [weak weakself = self] in
                weakself!.beaconRangeValue.text = String(weakself!.beaconRange!)
                if let range = weakself!.beaconRange, range > 0 {
                    weakself!.showBeacon = true
                } else {
                    weakself!.showBeacon = false
                }
            }
        }
    }
    private var nameRange: Int? {
        didSet {
            DispatchQueue.main.async {[weak weakself = self] in
                weakself!.nameRangeValue.text = String(weakself!.nameRange!)
                if let range = weakself!.nameRange, range > 0 {
                    weakself!.showName = true
                } else {
                    weakself!.showName = false
                }
            }
        }
    }
    private var noteRange: Int? {
        didSet {
            DispatchQueue.main.async { [weak weakself = self] in
                weakself!.noteRangeValue.text = String(weakself!.noteRange!)
                if let range = weakself!.noteRange, range > 0 {
                    weakself!.showNote = true
                } else {
                    weakself!.showNote = false
                }
            }
        }
    }
    
    @IBOutlet weak var waypointNameInput: UITextField!
    
    @IBOutlet weak var guideUserToggleText: UITextView!
    @IBOutlet weak var guideUserIcon: UIImageView!
    
    private let guideUserTrueText = "Automatically guide user to this location"
    private let doNotGuideUserText = "User will have to find this location on their own"
    
    @IBAction func guideUserToggle(_ sender: UIButton) {
        waypointToEdit!.showDirections = !waypointToEdit!.showDirections
            updateGuideUserSection()
    }
    
    private func updateGuideUserSection() {
        if waypointToEdit!.showDirections {
            guideUserToggleText.text = guideUserTrueText
            guideUserIcon.layer.opacity = 1.0
        } else {
            guideUserToggleText.text = doNotGuideUserText
            guideUserIcon.layer.opacity = 0.4
        }
    }
    
        
    @IBOutlet weak var beaconRangeLabel: UILabel!
    @IBOutlet weak var beaconRangeMinus: UIButton!
    @IBOutlet weak var beaconRangePlus: UIButton!
    @IBOutlet weak var beaconRangeValue: AllowableCharactersUITextField!

    @IBAction func beaconRangeSubtract(_ sender: UIButton) {
        beaconRange = safeIncrement(beaconRange!, incrementFunction: minus15)
    }
    @IBAction func beaconRangeAdd(_ sender: UIButton) {
        print("beacon range \(beaconRange)")
        beaconRange = safeIncrement(beaconRange!, incrementFunction: add15)
    }
    
    @IBOutlet weak var nameRangeLabel: UILabel!
    @IBOutlet weak var nameRangeMinus: UIButton!
    @IBOutlet weak var nameRangePlus: UIButton!
    @IBOutlet weak var nameRangeValue: AllowableCharactersUITextField!

    @IBAction func nameRangeSubtract(_ sender: UIButton) {
        nameRange = safeIncrement(nameRange!, incrementFunction: minus15)
    }
    @IBAction func nameRangeAdd(_ sender: UIButton) {
        nameRange = safeIncrement(nameRange!, incrementFunction: add15)
    }
    
    @IBOutlet weak var noteRangeLabel: UILabel!
    @IBOutlet weak var noteRangeMinus: UIButton!
    @IBOutlet weak var noteRangePlus: UIButton!
    @IBOutlet weak var noteRangeValue: AllowableCharactersUITextField!
    @IBOutlet weak var waypointNoteInput: UITextView!
  
    @IBAction func noteRangeSubtract(_ sender: UIButton) {
        noteRange = safeIncrement(noteRange!, incrementFunction: minus15)
        toggleDescriptionText()
    }
    @IBAction func noteRangeAdd(_ sender: UIButton) {
        noteRange = safeIncrement(noteRange!, incrementFunction: add15)
        toggleDescriptionText()
    }
    
    private func toggleDescriptionText() {
        if let range = noteRange, range > 0 {
            waypointNoteInput.layer.borderColor = UIColor.black.cgColor
            waypointNoteInput.layer.borderWidth = 1
            waypointNoteInput.isHidden = false
        } else {
            waypointNoteInput.isHidden = true
        }
    }
    
    private let maxRange = 99999
    private let minRange = 0
    
    private func safeIncrement(_ int: Int, incrementFunction: (Int) -> Int) -> Int {
        var newValue = incrementFunction(int)
        if newValue < minRange {
            newValue = minRange
        } else if newValue > maxRange {
            newValue = maxRange
        }
        return newValue
    }
    
    private func add15(_ int: Int) -> Int {
        return int + 15
    }
    
    private func minus15(_ int: Int) -> Int {
        return int - 15
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        updateUI()
        // Do any additional setup after loading the view.
    }
    
    private func updateUI() {
        if waypointToEdit != nil {
            DispatchQueue.main.async {[weak weakself = self] in
                weakself?.beaconRange = weakself?.waypointToEdit?.showBeaconWithinMeterRange ?? weakself?.defaultRangeValue
                weakself?.nameRange = weakself?.waypointToEdit?.showNameWithinMeterRange ?? weakself?.defaultRangeValue
                weakself?.noteRange = weakself?.waypointToEdit?.showDescriptionWithinMeterRange ?? weakself?.defaultRangeValue
                weakself?.waypointNameInput.text = weakself?.waypointToEdit?.title
                weakself?.waypointNameInput.returnKeyType = .done
                weakself?.waypointNameInput.delegate = self
                weakself?.waypointNoteInput.text = weakself?.waypointToEdit?.descriptionText
                weakself?.waypointNoteInput.returnKeyType = .done
                weakself?.waypointNoteInput.delegate = self
                weakself?.toggleDescriptionText()
                weakself?.updateGuideUserSection()
            }
        }
    }
    
    @objc
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    private func updateWaypoint() {
        if let newTitle = waypointNameInput.text, newTitle != "" {
            waypointToEdit?.title = newTitle
        }
        if showBeacon {
            waypointToEdit?.showBeaconWithinMeterRange = beaconRange
        } else {
            waypointToEdit?.showBeaconWithinMeterRange = nil
        }
        if showName {
            waypointToEdit?.showNameWithinMeterRange = nameRange
        } else {
            waypointToEdit?.showNameWithinMeterRange = nil
        }
        if showNote {
            waypointToEdit?.showDescriptionWithinMeterRange = noteRange
            waypointToEdit?.descriptionText = waypointNoteInput.text
        } else {
            waypointToEdit?.showDescriptionWithinMeterRange = nil
            waypointToEdit?.descriptionText = nil
        }
    }

    @IBAction func dismissPopup(_ sender: UIButton) {
        updateWaypoint()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteWaypoint(_ sender: UIButton) {
        deleteWaypointHook?(waypointToEdit!)
        dismiss(animated: true, completion: nil)
    }
    

}
