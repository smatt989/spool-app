//
//  Adventure.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/9/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation
import MapKit

class Adventure: NSObject {
    
    var name = ""
    var info: String? = ""
    var id: Int?
    var markers: [Marker] = [Marker](){
        didSet {
            markers.forEach{ marker in
                marker.markerChangeCallback = updateDirections
            }
            updateDirections()
        }
    }
    
    var directions = [Direction](){
        didSet {
            if directionsSet {
                print("GOT EM ALL")
                directionsSetCallback?()
            }
        }
    }
    
    var directionsSetCallback: (() -> Void)?
    
    var directionsSet: Bool {
        get {
            return numberOfRequiredDirections() == directions.count
        }
    }
    
    private func resetDirections() {
        directions = []
    }
    
    private func numberOfRequiredDirections() -> Int {
        return markers.count - 1
    }
    
    
    private func updateDirections() {
        print("Updating...")
        resetDirections()
        makeDirectionsForMarkerIndex(1)
    }
    
    private func makeDirectionsForMarkerIndex(_ index: Int){
        if markers.count > index && index > 0 {
            Direction.makeDirections(start: markers[index - 1], end: markers[index]){ [weak weakself = self] directionObject in
                weakself?.directions.append(directionObject)
            }
            //makeDirections(start: markers[index - 1], end: markers[index])
            makeDirectionsForMarkerIndex(index + 1)
        }
    }
}

class Marker: NSObject {
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var id: Int?
    var title: String? = ""
    var descriptionText: String?
    var showDirections: Bool = true
    var showBeaconWithinMeterRange: Int?
    var showNameWithinMeterRange: Int?
    var showDescriptionWithinMeterRange: Int?
    
    var markerChangeCallback: (() -> Void)?
    
    var location: CLLocation {
        get {
            return CLLocation(latitude: latitude, longitude: longitude)
        }
    }
}

extension Marker: MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
            markerChangeCallback?()
        }
    }
    
}

class Direction: NSObject {
    
    var start: Marker
    var end: Marker
    var route: MKRoute?
    
    init(start: Marker, end: Marker) {
        self.start = start
        self.end = end
        super.init()
    }
    
    private var currentStepIndex = 0
    
    var finished: Bool {
        get {
            return currentStepIndex >= orderedPoints.count
        }
    }
    
    var currentStep: CLLocationCoordinate2D? {
        get {
            if !finished {
                return orderedPoints[currentStepIndex]
            } else {
                return nil
            }
        }
    }
    
    func nextStep() {
        currentStepIndex += 1
    }
    
    func restart() {
        currentStepIndex = 0
    }
    
    var orderedPoints: [CLLocationCoordinate2D] {
        get {
            let polyline = route?.polyline
            var orderedPoints = [CLLocationCoordinate2D]()
            if polyline != nil {
                let rootcoordinates = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: polyline!.pointCount)
                
                polyline!.getCoordinates(rootcoordinates, range: NSMakeRange(0, polyline!.pointCount))
                
                for i in 0..<polyline!.pointCount {
                    orderedPoints.append(rootcoordinates[i])
                }
                
            }
            return orderedPoints
        }
    }
    
    static func makeDirections(start: Marker, end: Marker, callback: @escaping (Direction) -> Void) {
        let directionsRequest = MKDirectionsRequest()
        directionsRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: start.coordinate))
        directionsRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: end.coordinate))
        directionsRequest.transportType = .walking
        
        let directions = MKDirections(request: directionsRequest)
        directions.calculate { (response, error) in
            if let direction = response {
                let directionObject = Direction(start: start, end: end)
                directionObject.route = direction.routes[0]
                callback(directionObject)
            }
        }
    }
}
