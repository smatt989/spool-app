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
import CoreMotion
import AVKit
import AVFoundation

class EnterAdventureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate{

    var initialStepIndex = 0
    
    var continueAdventure = false
    
    private var captureSession: AVCaptureSession?
    
    private func startCamera() {
        let avCaptureSession = AVCaptureSession()
        let videoCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let videoInput = try! AVCaptureDeviceInput(device: videoCaptureDevice)
        avCaptureSession.addInput(videoInput)
        let newCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer.init(session: avCaptureSession)
        view.layer.masksToBounds = true
        newCaptureVideoPreviewLayer?.frame = view.bounds
        newCaptureVideoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        view.layer.insertSublayer(newCaptureVideoPreviewLayer!, below: view.layer.sublayers?[0])
        
        avCaptureSession.sessionPreset = AVCaptureSessionPresetHigh
        avCaptureSession.startRunning()
        
        captureSession = avCaptureSession
    }
    
    var userLocation: MKUserLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let id = adventureId {
            Adventure.fetchAdventure(id: id) { [weak weakself = self] adv in
                weakself?.adventure = adv
            }
        }
    }
    
    var adventureId: Int?
    
    var adventure: Adventure? {
        didSet {
            if adventure != nil {
                DispatchQueue.main.async { [weak weakself = self] in
                    weakself!.setupBeacons()
                    weakself!.setupNameLabels()
                    weakself!.setupNoteView()
                    if weakself!.continueAdventure {
                        AdventureProgress.get(adventureId: weakself!.adventureId!, success: { [weak weakweakself = self] in
                            weakweakself!.initialStepIndex = $0.step
                            weakweakself!.startDirections()
                            }, failure: {_ in 
                                print("SOMETHING BAD HAPPENED")
                        })
                    } else {
                        weakself?.startDirections()
                    }
                }
            }
        }
    }
    
    private let locationManager = CLLocationManager()
    
    private func instantiateLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    private func turnOffLocationManager() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        deviceMotion.stopDeviceMotionUpdates()
        captureSession?.stopRunning()
    }
    
    
    private struct Constants {
        static let rightWayRadianTolerance = M_PI * 5 / 8
        static let horizontalAccuracy = 10.0
        static let verticalAccuracy = 10.0
        static let distanceBetweenPointsAccuracy = 15.0
        static let headingAstrayDistance = 30.0
        static let tooMuchGpsVariation = 50.0
    }
    
    private var deviceMotion = CMMotionManager()
    
    private func startDeviceMotion() {
        deviceMotion.deviceMotionUpdateInterval = 0.05
        
        deviceMotion.startDeviceMotionUpdates(to: .main) { [weak weakself = self]
            (motion, error) in
            if let gravity = motion?.gravity {
                weakself?.latestGravity = gravity
            }
        }
    }
    
    private var latestGravity: CMAcceleration? {
        didSet {
            moveArrow()
            moveMarkerElements()
            showNoteView()
            //rotateLabel()
        }
    }
    private var latestLocation: CLLocation? {
        didSet {
            if distanceToNextCheckpoint != nil {
                DispatchQueue.main.async { [weak weakself = self] in
                    weakself?.doSomethingWithDistance(distance: self.distanceToNextCheckpoint!)
                }
            }
        }
    }
    private var latestHeading: CLLocationDirection?
    
    private func doSomethingWithDistance(distance: CLLocationDistance) {
        //PUT YOUR DISTANCE CODE HERE
    }
    
    private var distanceToNextCheckpoint: CLLocationDistance? {
        get {
            if latestLocation != nil && currentDestinationStep != nil {
                return distanceFromCoordinate(latestLocation!, coordinate: currentDestinationStep!)
            }
            return nil
        }
    }

    let arrow = Arrow()
    
    var beacons = [Beacon]()
    var nameLabels = [MarkerNameLabel]()
    
    var markerNoteView = NoteTextView()

    
    private func setupNoteView() {
        markerNoteView.setup(note: "", outerFrame: view.frame)
        markerNoteView.isHidden = true
        DispatchQueue.main.async { [weak weakself = self] in
            weakself?.view.insertSubview(weakself!.markerNoteView, at: 7)
        }
    }
    
    private func showNoteView() {
        if let loc = latestLocation, let adv = adventure, !finished {
            var looking = true
            var lookingAt = destinationMarkerIndex
            while looking && lookingAt >= 0 {
                let lookingAtMarker = adv.markers[lookingAt]
                if let range = lookingAtMarker.showDescriptionWithinMeterRange {
                    if loc.distance(from: CLLocation(latitude: lookingAtMarker.latitude, longitude: lookingAtMarker.longitude)) <= Double(range) {
                        markerNoteView.setup(note: lookingAtMarker.descriptionText ?? "", outerFrame: view.frame)
                        markerNoteView.isHidden = false
                        looking = false
                    }
                }
                lookingAt -= 1
            }
            if looking {
                markerNoteView.isHidden = true
            }
        }
    }
    
    private func setupBeacons() {
        beacons = (adventure?.markers
            .filter({ $0.showBeaconWithinMeterRange != nil}) ?? [])
            .map({marker in
                let beacon = Beacon()
                beacon.waypoint = marker
                beacon.setupBeacon(frame: view.frame)
                beacon.isHidden = true
                view.insertSubview(beacon, at: 2)
                return beacon
            })
    }
    
    private func setupNameLabels() {
        nameLabels = (adventure?.markers
            .filter({ $0.showNameWithinMeterRange != nil}) ?? [])
            .map({marker in
                let nameLabel = MarkerNameLabel()
                nameLabel.waypoint = marker
                nameLabel.setupLabel(outerFrame: view.frame)
                nameLabel.isHidden = true
                view.insertSubview(nameLabel, at: 3)
                return nameLabel
            })
    }
    
    private func moveMarkerElements() {
        if let loc = latestLocation {
            beacons.forEach{ beacon in
                if let waypoint = beacon.waypoint, let range = beacon.waypoint?.showBeaconWithinMeterRange {
                    let dist = loc.distance(from: CLLocation(latitude: waypoint.latitude, longitude: waypoint.longitude))
                    if dist <= Double(range) {
                        rotateLabel(element: beacon)
                    } else {
                        beacon.layer.isHidden = true
                    }
                }
            }
            nameLabels.forEach{ nameLabel in
                if let waypoint = nameLabel.waypoint, let range = nameLabel.waypoint?.showNameWithinMeterRange {
                    let dist = loc.distance(from: CLLocation(latitude: waypoint.coordinate.latitude, longitude: waypoint.coordinate.longitude))
                    if dist <= Double(range) {
                        rotateLabel(element: nameLabel)
                    } else {
                        nameLabel.isHidden = true
                    }
                }
            }
        }
    }
    
    private let minScale = 0.5
    
    private func scaleSize(dist: CLLocationDistance) -> Double{
        return 1 / (dist / 100.0 + 1) + minScale
    }
    
    private func scaleOffset(dist: CLLocationDistance) -> Double {
        return sqrt(dist)
    }

    let transformConstant = 1 / 500.0
    let pitchAdjust = M_PI / 9
    
    var adventureEndedLabel: UILabel?
    
    private func setupArrow() {
        arrow.setupArrow(frame: view.frame)
        arrow.layer.isHidden = true
        view.insertSubview(arrow, at: 5)
    }
    
    private func removeArrow() {
        arrow.removeFromSuperview()
    }
    
    private func setupAdventureEndedLabel() {
        let frame = view.frame
        adventureEndedLabel = UILabel(frame: CGRect(x: 0, y: 50, width: frame.maxX, height: 200))
        adventureEndedLabel!.backgroundColor = UIColor.clear
        adventureEndedLabel!.textAlignment = .center
        adventureEndedLabel!.text = "Adventure Complete!"
        adventureEndedLabel!.font = UIFont(name: adventureEndedLabel!.font.fontName, size: 30)
        adventureEndedLabel!.textColor = UIColor.init(red: 0.44, green: 0.96, blue: 0.31, alpha: 1.0)
        DispatchQueue.main.async { [weak weakself = self] in
            weakself?.view.addSubview(weakself!.adventureEndedLabel!)
        }
    }
    
    private var motionIsReady: Bool {
        get {
            return latestGravity != nil && latestLocation != nil && latestHeading != nil && currentDestinationStep != nil
        }
    }
    
    private func moveArrow() {
        if motionIsReady {
            if adventure?.markers[destinationMarkerIndex].showDirections ?? true {
                arrow.layer.isHidden = false
                var transform = CATransform3DIdentity
                transform.m34 = CGFloat(transformConstant)
                let result = ARMath.relativeOrientationOf(deviceOrientation: DeviceOrientation(gravity: latestGravity!, heading: latestHeading!) , at: latestLocation!.coordinate, to: currentDestinationStep!)
                let rollTransform = CATransform3DRotate(transform, CGFloat(-result.roll - result.yaw), 0, 0, 1)
                //let pitchTransform = CATransform3DRotate(transform, CGFloat(-result.pitch + pitchAdjust), 1, 0, 0)
                //let yawTransform = CATransform3DRotate(transform, CGFloat(-result.yaw), 0, 1, 0)
                //let transformer = CATransform3DConcat(yawTransform, CATransform3DConcat(rollTransform, pitchTransform))
                arrow.arrowView.layer.transform = rollTransform
            }  else {
                arrow.layer.isHidden = true
            }
        }
    }
    
    private func headingRightWay() -> Bool? {
        if motionIsReady {
            if adventure?.markers[destinationMarkerIndex].showDirections ?? true {
                let orientation = ARMath.relativeOrientationOf(deviceOrientation: DeviceOrientation(gravity: latestGravity!, heading: latestHeading!) , at: latestLocation!.coordinate, to: currentDestinationStep!)
                
                return orientation.roll < Constants.rightWayRadianTolerance && orientation.roll > -Constants.rightWayRadianTolerance
            }
        }
        return nil
    }
    
    private func rotateLabel(element: MarkerUIElement) {
        if let waypoint = element.waypoint, motionIsReady {
            var transform = CATransform3DIdentity
            transform.m34 = CGFloat(transformConstant)
            let result = ARMath.screenCoordinatesGivenOrientation(deviceOrientation: DeviceOrientation(gravity: latestGravity!, heading: latestHeading!), at: latestLocation!.coordinate, to: waypoint.coordinate)
            
            let distance = distanceFromCoordinate(latestLocation!, coordinate: waypoint.coordinate)
            if result.zPosition > 0 {
                element.layer.isHidden = false
                let translate = CATransform3DTranslate(transform, 0, -(CGFloat)(scaleOffset(dist: distance)), 0)
                let translation3d = CATransform3DMakeTranslation(CGFloat(result.x), CGFloat(result.y), 0)
                let rotation3d = CATransform3DRotate(transform, CGFloat(result.rotation), 0, 0, 1)
                let scalar = CATransform3DScale(transform, CGFloat(scaleSize(dist: distance)), CGFloat(scaleSize(dist: distance)), 1)
                element.layer.transform = CATransform3DConcat(CATransform3DConcat(CATransform3DConcat(translate, translation3d), rotation3d), scalar)
                element.layer.zPosition = CGFloat(1000000000.0 - (distance))
            } else {
                element.layer.isHidden = true
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        latestHeading = newHeading.trueHeading
//        if let h = headingRightWay() {
//            print("ON TRACK: \(h)")
//        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let previousLocation = latestLocation
        latestLocation = locations.last
        printToScreen(str: "UPDATING LOCATION")
        var onTrack = true
        if let mostRecentLocation = latestLocation, currentDirections != nil && currentDestinationStep != nil {
            
            //checks to see if there was a big GPS change, and if so refetches directions
            if previousLocation != nil {
                if mostRecentLocation.distance(from: previousLocation!) > Constants.tooMuchGpsVariation {
                    refreshMarker()
                    onTrack = false
                }
            }
            
            //checks to see if getting further away from next step, and if so refetches directions
            if let originalStepDistance = distanceToStep, onTrack {
                let distanceToStep = distanceFromCoordinate(mostRecentLocation, coordinate: currentDestinationStep!)
                if distanceToStep > originalStepDistance + Constants.headingAstrayDistance && !currentDirections!.finished {
                    refreshMarker()
                    onTrack = false
                }
            }

            if onTrack {
                if closeEnoughToCoordinate(mostRecentLocation, coordinate: currentDestinationStep!) {
                    currentDirections!.nextStep()
                    if currentDirections!.finished {
                        currentDestinationStep = currentDestination?.coordinate
                    } else {
                        printToScreen(str: "NEXT STEP")
                        currentDestinationStep = currentDirections!.currentStep
                    }
                }
                
                if closeEnoughToCoordinate(mostRecentLocation, coordinate: currentDestination!.coordinate) {
                    printToScreen(str: "NEXT MARKER")
                    nextMarker()
                }
            }
        }
    }
    
    private func closeEnoughToCoordinate(_ location: CLLocation, coordinate: CLLocationCoordinate2D) -> Bool {
        let distance = distanceFromCoordinate(location, coordinate: coordinate)
        return distance < Constants.distanceBetweenPointsAccuracy
    }
    
    private func distanceFromCoordinate(_ location: CLLocation, coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let targetMarker = CLLocation(coordinate: coordinate, altitude: location.altitude, horizontalAccuracy: CLLocationAccuracy(Constants.horizontalAccuracy), verticalAccuracy: CLLocationAccuracy(Constants.verticalAccuracy), timestamp: Date())
        return location.distance(from: targetMarker)
    }
    
    private var distanceToStep: CLLocationDistance?
    
    private var currentDestinationStep: CLLocationCoordinate2D? {
        didSet {
            distanceToStep = nil
            if currentDestinationStep != nil {
                let lat = currentDestinationStep!.latitude
                let lng = currentDestinationStep!.longitude
                let str = "heading to \(lat), \(lng)"
                printToScreen(str: str)
                
                if let mostRecentLocation = latestLocation {
                    distanceToStep = distanceFromCoordinate(mostRecentLocation, coordinate: currentDestinationStep!)
                }
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
        //turnOffLocationManager()
        removeArrow()
        setupAdventureEndedLabel()
    }
    
    private func nextMarker() {
        destinationMarkerIndex += 1
    }
    
    private func updateProgress(isFinished: Bool) {
        let progress = AdventureProgress(adventureId: adventureId!, step: destinationMarkerIndex, finished: isFinished, updated: NSDate())
        AdventureProgress.create(progress, success: {}, failure: {_ in print("Did not update")})
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
        updateProgress(isFinished: finished)
    }
    
    private func startDirections() {
        printToScreen(str: "STARTING DIRECTIONS")
        destinationMarkerIndex = initialStepIndex
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        beginAdventure()
    }
    
    private func beginAdventure() {
        setupArrow()
        instantiateLocationManager()
        startDeviceMotion()
        startCamera()
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.debugLog {
            if let controller = segue.destination as? DebugViewController {
                controller.text = toPrint
            }
        }
    }
}



