//
//  AdventureProgress.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/27/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation
import MapKit

struct AdventureProgress {
    let adventureId: Int
    let step: Int
    var finished: Bool = false
    var updated: NSDate = NSDate()
}

class AdventureInstance {

    var endAdventure: (() -> Void)?
    var startAdventureAddons: (() -> Void)?
    
    var continueAdventure = false
    
    private var setupCorrectly = false
    
    private var initialStepIndex = 0
    
    var step = -1 {
        didSet {
            updateCurrentDestination()
        }
    }
    
    var adventure: Adventure? {
        didSet{
            if adventure != nil {
                startAdventure()
            }
        }
    }
    
    private func startAdventure() {
        DispatchQueue.main.async { [weak weakself = self] in
            weakself?.startAdventureAddons?()
            if weakself!.continueAdventure {
                AdventureProgress.get(adventureId: weakself!.adventure!.id!, success: { [weak weakself = self] in
                    weakself!.initialStepIndex = $0.step
                    weakself!.startDirections()
                    }, failure: {_ in
                        print("SOMETHING BAD HAPPENED")
                })
            } else {
                weakself?.startDirections()
            }
        }
    }
    
    func startDirections(){
        if !setupCorrectly {
            step = initialStepIndex
        }
    }
    
    var user: User?
    
    var currentDestinationStep: CLLocationCoordinate2D? {
        didSet {
            distanceToStep = nil
            if currentDestinationStep != nil {
                setupCorrectly = true
                
                let lat = currentDestinationStep!.latitude
                let lng = currentDestinationStep!.longitude
                let str = "heading to \(lat), \(lng)"
                printToScreen?(str)
                
                if let mostRecentLocation = latestLocation {
                    distanceToStep = distanceFromCoordinate(mostRecentLocation, coordinate: currentDestinationStep!)
                }
            }
        }
    }
    
    var currentDirections: Direction? {
        didSet {
            if currentDirections != nil {
                currentDestinationStep = currentDirections?.currentStep
            }
        }
    }
    
    var currentDestination: Marker? {
        didSet {
            if currentDestination != nil {
                if let currentLocation = latestLocation?.coordinate {
                    let currentLocationMarker = Marker()
                    currentLocationMarker.coordinate = currentLocation
                    Direction.makeDirections(start: currentLocationMarker, end: currentDestination!) { [weak weakself = self] directions in
                        weakself?.currentDirections = directions
                    }
                }
            }
        }
    }
    
    var finished: Bool {
        get {
            return step >= adventure?.markers.count ?? 0
        }
    }
    
    var latestLocation: CLLocation? {
        didSet {
            if distanceToNextCheckpoint != nil {
                DispatchQueue.main.async { [weak weakself = self] in
                    weakself?.doSomethingWithDistance(distance: self.distanceToNextCheckpoint!)
                }
            }
        }
    }
    
        private func doSomethingWithDistance(distance: CLLocationDistance) {
            //PUT YOUR DISTANCE CODE HERE
        }
    
    var latestHeading: CLLocationDirection?
    var distanceToNextCheckpoint: CLLocationDistance? {
        get {
            if latestLocation != nil && currentDestinationStep != nil {
                return distanceFromCoordinate(latestLocation!, coordinate: currentDestinationStep!)
            }
            return nil
        }
    }
    
    var distanceToStep: CLLocationDistance?
    
    func distanceFromCoordinate(_ location: CLLocation, coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let targetMarker = CLLocation(coordinate: coordinate, altitude: location.altitude, horizontalAccuracy: CLLocationAccuracy(AdventureInstance.Constants.horizontalAccuracy), verticalAccuracy: CLLocationAccuracy(Constants.verticalAccuracy), timestamp: Date())
        return location.distance(from: targetMarker)
    }
    
    func headingRightWay(deviceOrientation: DeviceOrientation) -> Bool? {
        if adventure?.markers[step].showDirections ?? true {
            let orientation = ARMath.relativeOrientationOf(deviceOrientation: deviceOrientation, at: latestLocation!.coordinate, to: currentDestinationStep!)
            
            return orientation.roll < AdventureInstance.Constants.rightWayRadianTolerance && orientation.roll > -AdventureInstance.Constants.rightWayRadianTolerance
        }
        return nil
    }
    
    func updateProgress(isFinished: Bool) {
        let progress = AdventureProgress(adventureId: adventure!.id!, step: step, finished: isFinished, updated: NSDate())
        AdventureProgress.create(progress, success: {}, failure: {_ in print("Did not update")})
    }
    
    func refreshMarker() {
        printToScreen?("REFRESHING")
        updateCurrentDestination()
    }
    
    func updateCurrentDestination() {
        if !finished {
            currentDestination = adventure?.markers[step]
        } else {
            endAdventure?()
        }
        updateProgress(isFinished: finished)
    }
    
    func nextMarker() {
        step += 1
    }
    
    var printToScreen: ((String) -> Void)?
}

extension AdventureInstance {
    struct Constants {
        static let rightWayRadianTolerance = M_PI * 5 / 8
        static let horizontalAccuracy = 10.0
        static let verticalAccuracy = 10.0
        static let distanceBetweenPointsAccuracy = 15.0
        static let headingAstrayDistance = 30.0
        static let tooMuchGpsVariation = 50.0
    }
}
