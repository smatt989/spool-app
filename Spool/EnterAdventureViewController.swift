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
        locationManager.startUpdatingHeading()
    }
    
    private func turnOffLocationManager() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        deviceMotion.stopDeviceMotionUpdates()
        captureSession?.stopRunning()
    }
    
    
    private struct Constants {
        static let horizontalAccuracy = 10.0
        static let verticalAccuracy = 10.0
        static let distanceBetweenPointsAccuracy = 15.0
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
            executeThing()
            //rotateLabels()
        }
    }
    private var latestLocation: CLLocation?
    private var latestHeading: CLLocationDirection?
    
    let arrow = #imageLiteral(resourceName: "blue-arrow")
    var arrowView: UIImageView?
    var subview: UIView?
    let transformConstant = 1 / 500.0
    let pitchAdjust = M_PI / 9
    
    var label: UILabel?
    
    var star = #imageLiteral(resourceName: "star")
    var starView: UIImageView?
    var starSubview: UIView?
    
    
    private func setupArrow() {
        arrowView = UIImageView(image: arrow)
        subview = UIView(frame: view.frame)
        
        let imageWidth = subview!.frame.width / 3
        let imageRatio = imageWidth / arrowView!.frame.width
        let imageHeight = arrowView!.frame.height * imageRatio
        
        arrowView!.frame = CGRect(x: (subview!.frame.width - imageWidth) / 2, y: (subview!.frame.height - imageHeight) / 2, width: imageWidth, height: imageHeight)
        
        
        
        subview!.addSubview(arrowView!)
        view.insertSubview(subview!, at: 5)
    }
    
    private func setupLabel() {
        starView = UIImageView(image: star)
        starSubview = UIView(frame: view.frame)
        
        let imageWidth = subview!.frame.width / 3
        let imageRatio = imageWidth / starView!.frame.width
        let imageHeight = starView!.frame.height * imageRatio
        
        starView!.frame = CGRect(x: (starSubview!.frame.width - imageWidth) / 2, y: (starSubview!.frame.height - imageHeight) / 2, width: imageWidth, height: imageHeight)
        
        
        starView?.layer.shouldRasterize = true
        
        starSubview!.addSubview(starView!)
        view.insertSubview(starSubview!, at: 2)
//        
//        
//        
//        let width = 100.0
//        let height = 30.0
//        
//        label = UILabel(frame: CGRect(x: (Double(view.frame.maxX) - width) / 2, y: 200, width: width, height: height))
//        label?.backgroundColor = UIColor.black
//        label?.textColor = UIColor.white
//        label?.text = "OVER HERE!"
//        view.insertSubview(label!, at: 2)
    }
    
    private var motionIsReady: Bool {
        get {
            return latestGravity != nil && latestLocation != nil && latestHeading != nil && currentDestinationStep != nil
        }
    }
    
    private func executeThing() {
        if motionIsReady {
            var transform = CATransform3DIdentity
            transform.m34 = CGFloat(transformConstant)
            let result = ARMath.relativeOrientationOf(deviceOrientation: DeviceOrientation(gravity: latestGravity!, heading: latestHeading!) , at: latestLocation!.coordinate, to: currentDestinationStep!)
            let rollTransform = CATransform3DRotate(transform, CGFloat(-result.roll - result.yaw), 0, 0, 1)
            let pitchTransform = CATransform3DRotate(transform, CGFloat(-result.pitch + pitchAdjust), 1, 0, 0)
            let yawTransform = CATransform3DRotate(transform, CGFloat(-result.yaw), 0, 1, 0)
            let transformer = CATransform3DConcat(yawTransform, CATransform3DConcat(rollTransform, pitchTransform))
            arrowView?.layer.transform = transformer
            //print("OK THEN: yaw: \(result.yaw) pitch: \(result.pitch) roll: \(result.roll)")
        }
    }
    
    private func rotateLabels() {
        if motionIsReady {
            var transform = CATransform3DIdentity
            transform.m34 = CGFloat(transformConstant)
            let result = ARMath.screenCoordinatesGivenOrientation(deviceOrientation: DeviceOrientation(gravity: latestGravity!, heading: latestHeading!), at: latestLocation!.coordinate, to: currentDestinationStep!)
            if result.zPosition > 0 {
                starView?.layer.isHidden = false
                let translation3d = CATransform3DMakeTranslation(CGFloat(result.x), CGFloat(result.y), 0)
                let rotation3d = CATransform3DRotate(transform, CGFloat(result.rotation), 0, 0, 1)
                starView?.layer.transform = CATransform3DConcat(translation3d, rotation3d)
            } else {
                starView?.layer.isHidden = true
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        latestHeading = newHeading.trueHeading
    }
    
    private var locationUpdates = 0
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latestLocation = locations.last
        printToScreen(str: "UPDATING LOCATION")
        if currentDirections != nil && currentDestinationStep != nil {
            locationUpdates += 1
//            if locationUpdates % 10 == 0 {
//                //refreshMarker()
//            }
            
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
        setupArrow()
        //setupLabel()
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



