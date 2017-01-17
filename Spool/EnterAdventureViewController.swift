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

class EnterAdventureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, ARDelegate, ARMarkerDelegate, MarkerViewDelegate {
    
    internal func didTouchMarkerView(_ markerView: MarkerView) {
        //
    }

    
    
    var userLocation: MKUserLocation?
    var geoLocationsArray = [ARGeoCoordinate]()
    var _arController: AugmentedRealityController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if _arController == nil  {
            _arController = AugmentedRealityController(view: self.view, parentViewController: self, withDelgate: self)
            
            _arController.minimumScaleFactor = 0.5
            _arController.scaleViewsBasedOnDistance = true
            _arController.rotateViewsBasedOnPerspective = true
            _arController.debugMode = false
        }
    }
    
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
        _arController.locationManager.stopUpdatingLocation()
        _arController.stopListening()
    }
    
    
    private struct Constants {
        static let horizontalAccuracy = 10.0
        static let verticalAccuracy = 10.0
        static let distanceBetweenPointsAccuracy = 15.0
    }
    
    private var locationUpdates = 0
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        printToScreen(str: "UPDATING LOCATION")
        if currentDirections != nil && currentDestinationStep != nil {
            locationUpdates += 1
            if locationUpdates % 10 == 0 {
                refreshMarker()
            }
            
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
                
                removeGeoCoordinates()
                
                if let currentLocation = locationManager.location {
                    let newARCoord = makeArGeoCoordinate(step: currentDestinationStep!, currentLocation: currentLocation)
                    _arController.addCoordinate(newARCoord)
                }
            }
        }
    }
    
    private func removeGeoCoordinates() {
        for coord in _arController.coordinates {
            (coord as! ARGeoCoordinate).displayView.removeFromSuperview()
            _arController.removeCoordinate(coord as! ARGeoCoordinate)
        }
    }
    
    private func makeArGeoCoordinate(step: CLLocationCoordinate2D, currentLocation: CLLocation) -> ARGeoCoordinate{
        let stepLocation = CLLocation(coordinate: step, altitude: currentLocation.altitude, horizontalAccuracy: CLLocationAccuracy(Constants.horizontalAccuracy), verticalAccuracy: CLLocationAccuracy(Constants.verticalAccuracy), timestamp: Date())
        let coord = ARGeoCoordinate(location: stepLocation, locationTitle: "EEEK")!
        coord.calibrate(usingOrigin: currentLocation)
        
        let markerView = MarkerView(_coordinate: coord, _delegate: self)
        coord.displayView = markerView
        
        return coord
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
    
    private func refreshMarker() {
        printToScreen(str: "REFRESHING")
        updateCurrentDestination()
    }
    
    private var destinationMarkerIndex: Int = -1 {
        didSet {
            updateCurrentDestination()
        }
    }
    
    private func updateCurrentDestination() {
        if !finished {
            currentDestination = adventure?.markers[destinationMarkerIndex]
        } else {
            endAdventure()
        }
    }
    
    private func startDirections() {
        printToScreen(str: "STARTING DIRECTIONS")
        destinationMarkerIndex = 0
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
    
    private var toPrint = ""
    
    private func printToScreen(str: String) {
        toPrint.append("\n"+str)
//        DispatchQueue.main.async { [weak weakself = self] in
//            weakself?.printlog.text.append("\n"+str)
//        }
    }
    
    //@IBOutlet weak var printlog: UITextView!
    
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
    
    
    func didTapMarker(_ coordinate:ARGeoCoordinate) {
        //do nothing
    }
    func didUpdate(_ newHeading:CLHeading){
        //do nothing
    }
    func didUpdate(_ newLocation:CLLocation){
        //do nothing
    }
    func didUpdate(_ orientation:UIDeviceOrientation) {
        //do nothing
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("IN THE MIX")
        if segue.identifier == Identifiers.debugLog {
            print("IN THE CONTROLLER")
            if let controller = segue.destination as? DebugViewController {
                print("IN THE VIEW")
                controller.text = toPrint
            }
        }
    }
 

}
