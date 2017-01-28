//
//  LocationFinder.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/27/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation
import CoreLocation

class LocationFinder: NSObject, CLLocationManagerDelegate {
    
    init(callback: @escaping (CLLocation) -> Void) {
        self.callback = callback
    }
    
    func findLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    private var callback: (CLLocation) -> Void
    
    private var locationManager = CLLocationManager()
    
    private var currentLocation: CLLocation? {
        didSet {
            if currentLocation != nil {
                callback(currentLocation!)
            }
        }
    }
    
    private func stopLocationManager() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            if lastLocation.verticalAccuracy <= 100 && lastLocation.horizontalAccuracy <= 100 {
                currentLocation = lastLocation
                stopLocationManager()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        findLocation()
    }
}
