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
            print("SETTING")
            adventure?.directionsSetCallback = setOrderedPoints
        }
    }
    
    private let locationManager = CLLocationManager()
    
    private func instantiateLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    private func turnOffLocationManager() {
        locationManager.stopUpdatingLocation()
    }
    
    
    private struct Constants {
        static let horizontalAccuracy = 10.0
        static let verticalAccuracy = 10.0
        static let distanceBetweenPointsAccuracy = 10.0
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if currentDestinationStep != nil {
            let mostRecentLocation = locations.last!
            let targetLocation = CLLocation(coordinate: currentDestinationStep!, altitude: mostRecentLocation.altitude, horizontalAccuracy: CLLocationAccuracy(Constants.horizontalAccuracy), verticalAccuracy: CLLocationAccuracy(Constants.verticalAccuracy), timestamp: Date())

            if mostRecentLocation.distance(from: targetLocation) < Constants.distanceBetweenPointsAccuracy {
                nextStep()
            }
        }
    }
    
    private var currentStepIndex = 0
    
    private var currentDestinationStep: CLLocationCoordinate2D?
    
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
    
    private var currentDirections: Direction? {
        didSet {
            currentStepIndex = 0
            if let path = currentDirections {
                path.orderedPoints
                
            }
        }
    }
    
    private func nextDirections(){
        
    }
    
    private func nextStep() {
        
    }
    
    private func startDirections() {
        currentDestination = adventure?.markers.first
    }
    
    var orderedPoints: [MKMapPoint]?
    
    private func setOrderedPoints() {
        print("in the function")
        let polyline = adventure?.directions[0].route?.polyline
        if polyline != nil {
            print("Made it")
            //var coords: [CLLocationCoordinate2D] = []
            let rootcoordinates = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: polyline!.pointCount)
            //coords.reserveCapacity(polyline!.pointCount)
            polyline!.getCoordinates(rootcoordinates, range: NSMakeRange(0, polyline!.pointCount))
            //print("THIS MANY COORDS: %@ and this many points: %@", coords.count, polyline!.pointCount)
            
            for i in 0..<polyline!.pointCount {
                print("%@, %@",rootcoordinates[i].latitude, rootcoordinates[i].longitude)
            }

        }
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
