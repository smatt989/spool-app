//
//  WaypointToolbarExtension.swift
//  Spool
//
//  Created by Matthew Slotkin on 2/1/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation
import MapKit

extension AdventureEditingViewController: UITextFieldDelegate, UITextViewDelegate {
    
    func updateUI() {
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
    
    private func hitButton(_ action: ActionItem){
        hideNoteView()
        if currentlyEditing == action {
            currentlyEditing = .none
        } else {
            currentlyEditing = action
        }
    }
    
    private func deselectButton(_ button: UIButton){
        button.backgroundColor = UIColor.lightGray
    }
    
    private func selectButton(_ button: UIButton) {
        removeCircle()
        button.backgroundColor = UIColor.white
    }
    
    @IBAction func showDirectionsButtonTap(_ sender: UIButton) {
        hitButton(.directions)
        turnAllButtonsInactive()
        waypointToEdit!.showDirections = !waypointToEdit!.showDirections
        updateUI()
    }
    
    @IBAction func showBeaconButtonPress(_ sender: UIButton) {
        hitButton(.beacon)
        activateButton(sender)
        if currentlyEditing != .none {
            selectButton(showBeaconButton)
            addRadiusCircle(radius: CLLocationDistance(waypointToEdit!.showBeaconWithinMeterRange ?? defaultRange))
        } else {
            deselectButton(showBeaconButton)
            waypointToEdit?.showBeaconWithinMeterRange = nil
            removeCircle()
        }
    }
    
    @IBAction func showNameButtonPress(_ sender: UIButton) {
        hitButton(.name)
        activateButton(sender)
        if currentlyEditing != .none {
            selectButton(showNameButton)
            addRadiusCircle(radius: CLLocationDistance(waypointToEdit!.showNameWithinMeterRange ?? defaultRange))
        } else {
            deselectButton(showNameButton)
            waypointToEdit?.showNameWithinMeterRange = nil
            removeCircle()
        }
    }
    
    @IBAction func showNoteButtonPress(_ sender: UIButton) {
        hitButton(.note)
        activateButton(sender)
        if currentlyEditing != .none {
            selectButton(showNoteButton)
            addRadiusCircle(radius: CLLocationDistance(waypointToEdit!.showDescriptionWithinMeterRange ?? defaultRange))
            showNoteView()
        } else {
            deselectButton(showNoteButton)
            waypointToEdit?.showDescriptionWithinMeterRange = nil
            removeCircle()
        }
    }
    
    @IBAction func deleteWaypointButtonPress(_ sender: UIButton) {
        removeAnnotation(waypointToEdit!)
        dismissToolbar()
    }
    
    private var interactionButtons: [UIButton] {
        get {
            return [showBeaconButton, showNameButton, showNoteButton]
        }
    }
    
    private func turnAllButtonsInactive() {
        interactionButtons.forEach{button in
            button.layer.borderWidth = 0
        }
    }
    
    private func activateButton(_ button: UIButton) {
        turnAllButtonsInactive()
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.blue.cgColor
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //performSegue(withIdentifier: Identifiers.editMarkerPopoverSegue, sender: view)
        //mapView.deselectAnnotation(view.annotation, animated: true)
        waypointToolbar.isHidden = false
        let marker = view.annotation as? Marker
        waypointToEdit = marker
    }
    
    private func showNoteView() {
        let superFrame = view.frame
        let frame = CGRect(x: 0, y: 100, width: superFrame.maxX, height: 40)
        noteView.delegate = self
        noteView.frame = frame
        noteView.text = waypointToEdit?.descriptionText
        noteView.isHidden = false
        noteView.backgroundColor = UIColor.black
        noteView.alpha = 0.8
        noteView.textColor = UIColor.white
        view.insertSubview(noteView, at: 10)
        noteView.returnKeyType = .done
        noteView.becomeFirstResponder()
        listenToTextFields()
    }
    
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
    
    private func addPinchGesture() {
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchedView(_:)))
        pinchGestureRecognizer!.delegate = self
        mapView.isZoomEnabled = false
        //mapView.isUserInteractionEnabled = false
        mapView.addGestureRecognizer(pinchGestureRecognizer!)
    }
    
    private func removePinchGesture() {
        mapView.isZoomEnabled = true
        //mapView.isUserInteractionEnabled = true
        mapView.removeGestureRecognizer(pinchGestureRecognizer!)
    }
    
    @objc
    func pinchedView(_ sender:UIPinchGestureRecognizer){
        let newRadius = (circle!.radius * Double(sender.scale)) as CLLocationDistance
        updateCircle(radius: newRadius)
        updateRange(radius: newRadius)
        sender.scale = 1.0
    }
    
    func addRadiusCircle(radius: CLLocationDistance){
        print("ADDING THIS RADIUS: \(radius)")
        updateCircle(radius: radius)
        drawDirections()
        updateRange(radius: radius)
        addPinchGesture()
    }
    
    func updateRange(radius: CLLocationDistance){
        let range = Int(round(radius))
        switch currentlyEditing {
        case .beacon: waypointToEdit?.showBeaconWithinMeterRange = range
        case .name: waypointToEdit?.showNameWithinMeterRange = range
        case .note: waypointToEdit?.showDescriptionWithinMeterRange = range
        default: break
        }
    }
    
    private func updateCircle(radius: CLLocationDistance) {
        print("radius \(radius)")
        let newCircle = MKCircle(center: waypointToEdit!.coordinate, radius: radius)
        DispatchQueue.main.async { [weak weakself = self] in
            if weakself?.circle != nil {
                weakself!.mapView.remove(weakself!.circle!)
            }
            weakself!.mapView.add(newCircle)
            weakself!.circle = newCircle
        }
    }
    
    func removeCircle() {
        if circle != nil {
            removePinchGesture()
            mapView!.remove(circle!)
            circle = nil
        }
    }
    
    func dismissToolbar() {
        waypointToEdit = nil
        hideNoteView()
        waypointToolbar.isHidden = true
        removeCircle()
    }
}
