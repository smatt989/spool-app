//
//  WaypointToolbarViewController.swift
//  Spool
//
//  Created by Matthew Slotkin on 2/1/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit
import MapKit

class WaypointToolbarViewController: AdventureEditingViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        waypointToolbar.isHidden = true
        waypointToolbar.mapview = mapView
        waypointToolbar.removeMarkerCallback = removeAnnotation
        waypointToolbar.addRadiusCircle = addRadiusCircle
        waypointToolbar.removeCircle = removeCircle
    }
    
    private func dismissToolbar() {
        waypointToolbar.dismissSelf()
    }
    
    override func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        super.mapView(mapView, didDeselect: view)
        
        dismissToolbar()
    }
    
    @IBOutlet weak var waypointToolbar: WaypointToolbar!
    
    var pinchGestureRecognizer: UIPinchGestureRecognizer?
    
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
    
    private var circle: MKCircle? {
        didSet {
            if circle != nil {
                waypointToolbar.updateRange(radius: circle!.radius)
            }
        }
    }
    
    func addRadiusCircle(location: CLLocation, radius: CLLocationDistance){
        print("ADDING THIS RADIUS: \(radius)")
        circle = MKCircle(center: location.coordinate, radius: radius as CLLocationDistance)
        mapView.add(circle!)
        addPinchGesture()
    }
    
    @objc
    func pinchedView(_ sender:UIPinchGestureRecognizer){
        print("PINCHING...")
        updateCircle(radius: (circle!.radius * Double(sender.scale)) as CLLocationDistance)
        sender.scale = 1.0
    }
    
    private func updateCircle(radius: CLLocationDistance) {
        print("radius \(radius)")
        let newCircle = MKCircle(center: circle!.coordinate, radius: radius)
        DispatchQueue.main.async { [weak weakself = self] in
            weakself!.mapView.remove(weakself!.circle!)
            weakself!.mapView.add(newCircle)
            weakself!.circle = newCircle
        }
    }
    
    func removeCircle() {
        if circle != nil {
            removePinchGesture()
            mapView!.remove(circle!)
        }
    }

}
