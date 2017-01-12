//
//  EnterAdventureViewController.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/11/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit
import MapKit
import CoreImage

class EnterAdventureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

    var adventureId: Int? {
        didSet {
            if let id = adventureId {
                Adventure.fetchAdventure(id: id) { adv in
                    self.adventure = adv
                }
            } else {
                adventure = nil
            }
        }
    }
    
    var adventure: Adventure? {
        didSet {
            if adventure != nil {
                startDirections()
            }
        }
    }
    
    private let locationManager = CLLocationManager()
    
    private func instantiateLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    private func turnOffLocationManager() {
        locationManager.stopUpdatingLocation()
    }
    
    
    private struct Constants {
        static let horizontalAccuracy = 10.0
        static let verticalAccuracy = 10.0
        static let distanceBetweenPointsAccuracy = 15.0
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        printToScreen(str: "UPDATING LOCATION")
        if currentDirections != nil && currentDestinationStep != nil {
            let mostRecentLocation = locations.last!
            let targetLocation = CLLocation(coordinate: currentDestinationStep!, altitude: mostRecentLocation.altitude, horizontalAccuracy: CLLocationAccuracy(Constants.horizontalAccuracy), verticalAccuracy: CLLocationAccuracy(Constants.verticalAccuracy), timestamp: Date())
            
            let distanceFromStep = mostRecentLocation.distance(from: targetLocation)
            printToScreen(str: "distance: \(distanceFromStep)")

            if distanceFromStep < Constants.distanceBetweenPointsAccuracy {
                currentDirections!.nextStep()
                if currentDirections!.finished {
                    let targetMarker = CLLocation(coordinate: currentDestination!.coordinate, altitude: mostRecentLocation.altitude, horizontalAccuracy: CLLocationAccuracy(Constants.horizontalAccuracy), verticalAccuracy: CLLocationAccuracy(Constants.verticalAccuracy), timestamp: Date())
                    if mostRecentLocation.distance(from: targetMarker) < Constants.distanceBetweenPointsAccuracy {
                        printToScreen(str: "NEXT MARKER")
                        nextMarker()
                    } else {
                        printToScreen(str: "NOT QUITE THERE")
                        currentDestinationStep = currentDestination?.coordinate
                    }
                } else {
                    printToScreen(str: "NEXT STEP")
                    currentDestinationStep = currentDirections!.currentStep
                }
            }
        }
    }
    
    private var currentDestinationStep: CLLocationCoordinate2D? {
        didSet {
            if currentDestinationStep != nil {
                let lat = currentDestinationStep!.latitude
                let lng = currentDestinationStep!.longitude
                let str = "heading to \(lat), \(lng)"
                printToScreen(str: str)
            }
        }
    }
    
    private var currentDirections: Direction? {
        didSet {
            if currentDirections != nil {
                currentDestinationStep = currentDirections?.currentStep
            }
        }
    }
    
    private var currentDestination: Marker? {
        didSet {
            if currentDestination != nil {
                if let currentLocation = locationManager.location?.coordinate {
                    let currentLocationMarker = Marker()
                    currentLocationMarker.coordinate = currentLocation
                    Direction.makeDirections(start: currentLocationMarker, end: currentDestination!) { [weak weakself = self] directions in
                        weakself?.currentDirections = directions
                    }
                }
            }
        }
    }
    
    private var finished: Bool {
        get {
            return destinationMarkerIndex >= adventure?.markers.count ?? 0
        }
    }
    
    private func endAdventure() {
        printToScreen(str: "FINISHED ADVENTURE!")
        turnOffLocationManager()
    }
    
    private func nextMarker() {
        destinationMarkerIndex += 1
    }
    
    private var destinationMarkerIndex: Int = -1 {
        didSet {
            if !finished {
                currentDestination = adventure?.markers[destinationMarkerIndex]
            } else {
                endAdventure()
            }
        }
    }
    
    private func startDirections() {
        printToScreen(str: "STARTING DIRECTIONS")
        destinationMarkerIndex = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        instantiateLocationManager()
        //launchCamera()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        turnOffLocationManager()
    }
    
    private func printToScreen(str: String) {
        DispatchQueue.main.async { [weak weakself = self] in
            weakself?.printlog.text.append("\n"+str)
        }
    }
    
    @IBOutlet weak var printlog: UITextView!
    
    private func launchCamera() {
        if UIImagePickerController.isCameraDeviceAvailable(.rear) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            imagePicker.showsCameraControls = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
