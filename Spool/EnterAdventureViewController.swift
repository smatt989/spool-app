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
import SpriteKit

class EnterAdventureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate{
    
    var continueAdventure = false
    
    let adventureInstance = AdventureInstance()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let id = adventureId {
            Adventure.fetchAdventure(id: id) { [weak weakself = self] adv in
                weakself?.adventureInstance.endAdventure = weakself?.endAdventure
                weakself?.adventureInstance.continueAdventure = weakself!.continueAdventure
                weakself?.adventureInstance.startAdventureAddons = weakself?.setupARElements
                weakself?.adventureInstance.adventure = adv
            }
        }
    }
    
    private func setupARElements() {
        DispatchQueue.main.async { [weak weakself = self] in
            weakself!.setupBeacons()
            weakself!.setupNameLabels()
            weakself!.setupNoteView()
        }
    }
    
    var adventureId: Int?
    
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

    let arrow = Arrow()
    
    var beacons = [GeoARElement]()
    var nameLabels = [GeoARElement]()
    
    var markerNoteView = NoteTextView()

    
    private func setupNoteView() {
        markerNoteView.setup(note: "", outerFrame: view.frame)
        markerNoteView.isHidden = true
        DispatchQueue.main.async { [weak weakself = self] in
            weakself?.view.insertSubview(weakself!.markerNoteView, at: 7)
        }
    }
    
    private func showNoteView() {
        if let loc = adventureInstance.latestLocation, let adv = adventureInstance.adventure, !adventureInstance.finished {
            var looking = true
            var lookingAt = adventureInstance.step
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
        beacons = (adventureInstance.adventure?.markers
            .filter({ $0.showBeaconWithinMeterRange != nil}) ?? [])
            .map({marker in
                let arElement = GeoARElement()
                arElement.waypoint = marker
                arElement.uiElement = Beacon()
                arElement.setup(view: view)
                return arElement
            })
    }
    
    private func setupNameLabels() {
        nameLabels = (adventureInstance.adventure?.markers
            .filter({ $0.showNameWithinMeterRange != nil}) ?? [])
            .map({marker in
                let arElement = GeoARElement()
                arElement.waypoint = marker
                arElement.uiElement = MarkerNameLabel()
                arElement.setup(view: view)
                return arElement
            })
    }
    
    private func moveMarkerElements() {
        if let loc = adventureInstance.latestLocation {
            beacons.forEach{ beacon in
                if let waypoint = beacon.waypoint, let range = beacon.waypoint?.showBeaconWithinMeterRange {
                    let dist = loc.distance(from: CLLocation(latitude: waypoint.latitude, longitude: waypoint.longitude))
                    if dist <= Double(range) {
                        rotateLabel(element: beacon)
                    } else {
                        beacon.uiElement!.layer.isHidden = true
                    }
                }
            }
            nameLabels.forEach{ nameLabel in
                if let waypoint = nameLabel.waypoint, let range = nameLabel.waypoint?.showNameWithinMeterRange {
                    let dist = loc.distance(from: CLLocation(latitude: waypoint.coordinate.latitude, longitude: waypoint.coordinate.longitude))
                    if dist <= Double(range) {
                        rotateLabel(element: nameLabel)
                    } else {
                        nameLabel.uiElement!.layer.isHidden = true
                    }
                }
            }
        }
    }

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
            
//            print("gravity is not nil: \(latestGravity != nil)")
//            print("location is not nil: \(adventureInstance.latestLocation != nil)")
//            print("heading is not nil: \(adventureInstance.latestHeading != nil)")
//            print("destination is not nil: \(adventureInstance.currentDestinationStep != nil)")
            
            return latestGravity != nil && adventureInstance.latestLocation != nil && adventureInstance.latestHeading != nil && adventureInstance.currentDestinationStep != nil
        }
    }
    
    private func moveArrow() {
        if motionIsReady && !adventureInstance.finished{
            if adventureInstance.adventure?.markers[adventureInstance.step].showDirections ?? true {
                arrow.layer.isHidden = false
                var transform = CATransform3DIdentity
                transform.m34 = CGFloat(AdventureUtilities.transformConstant)
                let result = ARMath.relativeOrientationOf(deviceOrientation: DeviceOrientation(gravity: latestGravity!, heading: adventureInstance.latestHeading!) , at: adventureInstance.latestLocation!.coordinate, to: adventureInstance.currentDestinationStep!)
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
            let deviceOrientation = DeviceOrientation(gravity: latestGravity!, heading: adventureInstance.latestHeading!)
            return adventureInstance.headingRightWay(deviceOrientation: deviceOrientation)
        } else {
            return nil
        }
    }
    
    private func rotateLabel(element: GeoARElement) {
        if let waypoint = element.waypoint, motionIsReady {
            let result = ARMath.screenCoordinatesGivenOrientation(deviceOrientation: DeviceOrientation(gravity: latestGravity!, heading: adventureInstance.latestHeading!), at: adventureInstance.latestLocation!.coordinate, to: waypoint.coordinate)
            
            let distance = adventureInstance.distanceFromCoordinate(adventureInstance.latestLocation!, coordinate: waypoint.coordinate)
            element.rotate(rotation: result, distance: distance, view: view)
        }
    }
        
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        adventureInstance.latestHeading = newHeading.trueHeading
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let previousLocation = adventureInstance.latestLocation
        adventureInstance.latestLocation = locations.last
        adventureInstance.startDirections()
        printToScreen(str: "UPDATING LOCATION")
        var onTrack = true
        if let mostRecentLocation = adventureInstance.latestLocation, adventureInstance.currentDirections != nil && adventureInstance.currentDestinationStep != nil {
            
            //checks to see if there was a big GPS change, and if so refetches directions
            if previousLocation != nil {
                if mostRecentLocation.distance(from: previousLocation!) > AdventureInstance.Constants.tooMuchGpsVariation {
                    adventureInstance.refreshMarker()
                    onTrack = false
                }
            }
            
            //checks to see if getting further away from next step, and if so refetches directions
            if let originalStepDistance = adventureInstance.distanceToStep, onTrack {
                let distanceToStep = adventureInstance.distanceFromCoordinate(mostRecentLocation, coordinate: adventureInstance.currentDestinationStep!)
                if distanceToStep > originalStepDistance + AdventureInstance.Constants.headingAstrayDistance && !adventureInstance.currentDirections!.finished {
                    adventureInstance.refreshMarker()
                    onTrack = false
                }
            }

            if onTrack {
                if closeEnoughToCoordinate(mostRecentLocation, coordinate: adventureInstance.currentDestinationStep!) {
                    adventureInstance.currentDirections!.nextStep()
                    if adventureInstance.currentDirections!.finished {
                        adventureInstance.currentDestinationStep = adventureInstance.currentDestination?.coordinate
                    } else {
                        printToScreen(str: "NEXT STEP")
                        adventureInstance.currentDestinationStep = adventureInstance.currentDirections!.currentStep
                    }
                }
                
                if closeEnoughToCoordinate(mostRecentLocation, coordinate: adventureInstance.currentDestination!.coordinate) {
                    printToScreen(str: "NEXT MARKER")
                    adventureInstance.nextMarker()
                }
            }
        }
    }
    
    private func closeEnoughToCoordinate(_ location: CLLocation, coordinate: CLLocationCoordinate2D) -> Bool {
        let distance = adventureInstance.distanceFromCoordinate(location, coordinate: coordinate)
        return distance < AdventureInstance.Constants.distanceBetweenPointsAccuracy
    }
    
    private func endAdventure() {
//        let firework = SKSpriteNode(fileNamed: "MyParticle")
//        firework?.position = CGPoint(x: 100, y: 200)
//        let skview = SKView(frame: CGRect(x: 100, y: 200, width: 200, height: 200))
//        let scene = SKScene(size: CGSize(width: 500, height: 500))
//        scene.addChild(firework!)
//        scene.backgroundColor = UIColor.clear
//        skview.presentScene(scene)
//        skview.allowsTransparency = true
//        view.insertSubview(skview, at: 5)
        printToScreen(str: "FINISHED ADVENTURE!")
        //turnOffLocationManager()
        removeArrow()
        setupAdventureEndedLabel()
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
        captureSession?.stopRunning()
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



