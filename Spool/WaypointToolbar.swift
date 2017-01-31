//
//  WaypointToolbar.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/30/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit
import MapKit

class WaypointToolbar: UIView {
    
    var waypointToEdit: Marker? {
        didSet {
            if waypointToEdit != nil {
                updateUI()
            }
        }
    }
    var mapview: MKMapView?
    
    var addRadiusCircle: ((CLLocation, CLLocationDistance) -> Void)?
    var removeCircle: (() -> Void)?
    
    var removeMarkerCallback: ((Marker) -> Void)?
    
    func updateRange(radius: CLLocationDistance){
        let range = Int(round(radius))
        switch currentlyEditing {
        case .beacon: waypointToEdit?.showBeaconWithinMeterRange = range
        case .name: waypointToEdit?.showNameWithinMeterRange = range
        case .note: waypointToEdit?.showDescriptionWithinMeterRange = range
        default: break
        }
    }
    
    var viewController: AdventureEditingViewController?
    
    private var location: CLLocation {
        get {
            return CLLocation(latitude: waypointToEdit!.latitude, longitude: waypointToEdit!.longitude)
        }
    }
    
    private var currentlyEditing: ActionItem = .none
    
    private let defaultRange = 25

    @IBOutlet weak var showDirectionsButton: UIButton!
    @IBOutlet weak var showBeaconButton: UIButton!
    @IBOutlet weak var showNameButton: UIButton!
    @IBOutlet weak var showNoteButton: UIButton!
    @IBOutlet weak var deleteWaypointButton: UIButton!
    
    @IBAction func showDirectionsButtonTap(_ sender: UIButton) {
        hitButton(.directions)
        waypointToEdit!.showDirections = !waypointToEdit!.showDirections
        updateUI()
    }
    
    @IBAction func showBeaconButtonPress(_ sender: UIButton) {
        hitButton(.beacon)
        if currentlyEditing != .none {
            selectButton(showBeaconButton)
            addRadiusCircle?(location, CLLocationDistance(waypointToEdit!.showBeaconWithinMeterRange ?? defaultRange))
        } else {
            deselectButton(showBeaconButton)
            waypointToEdit?.showBeaconWithinMeterRange = nil
            removeCircle?()
        }
    }
    
    @IBAction func showNameButtonPress(_ sender: UIButton) {
        hitButton(.name)
        if currentlyEditing != .none {
            selectButton(showNameButton)
            addRadiusCircle?(location, CLLocationDistance(waypointToEdit!.showNameWithinMeterRange ?? defaultRange))
        } else {
            deselectButton(showNameButton)
            waypointToEdit?.showNameWithinMeterRange = nil
            removeCircle?()
        }
    }
    
    @IBAction func showNoteButtonPress(_ sender: UIButton) {
        hitButton(.note)
        if currentlyEditing != .none {
            selectButton(showNoteButton)
            addRadiusCircle?(location, CLLocationDistance(waypointToEdit!.showDescriptionWithinMeterRange ?? defaultRange))
            showNoteView()
        } else {
            deselectButton(showNoteButton)
            waypointToEdit?.showDescriptionWithinMeterRange = nil
            removeCircle?()
        }
    }
    
    @IBAction func deleteWaypointButtonPress(_ sender: UIButton) {
        removeMarkerCallback?(waypointToEdit!)
        self.isHidden = true
    }
    
    private enum ActionItem {
        case directions
        case beacon
        case name
        case note
        case none
    }
    
    private func hitButton(_ action: ActionItem){
        hideNoteView()
        if currentlyEditing == action {
            currentlyEditing = .none
        } else {
            currentlyEditing = action
        }
    }
    
    var noteView = UITextView()
    
    private func showNoteView() {
        let superFrame = superview!.frame
        let frame = CGRect(x: 0, y: 100, width: superFrame.maxX, height: 40)
        noteView.frame = frame
        print("WAYPOINT TEXT: \(waypointToEdit?.descriptionText)")
        noteView.text = waypointToEdit?.descriptionText
        noteView.isHidden = false
        noteView.backgroundColor = UIColor.black
        noteView.alpha = 0.8
        noteView.textColor = UIColor.white
        superview?.insertSubview(noteView, at: 10)
        listenToTextFields()
    }
    
    private var noteObserver: NSObjectProtocol?
    
    private func listenToTextFields() {
        let center = NotificationCenter.default
        let queue = OperationQueue.main
        
        noteObserver = center.addObserver(
            forName: Notification.Name.UITextViewTextDidChange,
            object: noteView,
            queue: queue){ [weak weakself = self] notification in
                if let waypoint = weakself?.waypointToEdit {
                    waypoint.descriptionText = weakself?.noteView.text
                }
        }
    }
    
    private func stopListening() {
        if let observer = noteObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func hideNoteView() {
        stopListening()
        noteView.removeFromSuperview()
        noteView.isHidden = true
    }
    
    func dismissSelf() {
        hideNoteView()
        isHidden = true
        removeCircle?()
    }
    
    private func updateUI() {
        print("UPDATING UI")
        if waypointToEdit!.showDirections {
            selectButton(showDirectionsButton)
        } else {
            deselectButton(showDirectionsButton)
        }
        
        if waypointToEdit!.showBeaconWithinMeterRange != nil {
            selectButton(showBeaconButton)
        } else {
            deselectButton(showBeaconButton)
        }
        
        if waypointToEdit!.showNameWithinMeterRange != nil {
            selectButton(showNameButton)
        } else {
            deselectButton(showNameButton)
        }
        
        if waypointToEdit!.showDescriptionWithinMeterRange != nil {
            selectButton(showNoteButton)
        } else {
            deselectButton(showNoteButton)
        }
        
        currentlyEditing = .none
    }
    
    private func deselectButton(_ button: UIButton){
        button.backgroundColor = UIColor.lightGray
    }
    
    private func selectButton(_ button: UIButton) {
        removeCircle?()
        button.backgroundColor = UIColor.white
    }

}
