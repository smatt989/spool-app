//
//  AdventureEditingViewController.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/9/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit
import MapKit

class AdventureEditingViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var adventureId: Int? {
        didSet {
            if let id = adventureId {
                Adventure.fetchAdventure(id: id) { adv in
                    self.adventure = adv
                }
            } else {
                adventure = Adventure()
            }
        }
    }
    
    var adventure: Adventure? {
        didSet {
            adventure?.directionsSetCallback = drawDirections
            DispatchQueue.main.async { [weak weakself = self] in
                weakself?.updateMapUI()            }
        }
    }
    
    private var isNewAdventure: Bool {
        get {
            return adventureId == nil
        }
    }
    
    private var locationFinder: LocationFinder?
    
    private func moveToCurrentLocation() {
        locationFinder = LocationFinder(callback: panToUserLocation)
        locationFinder!.findLocation()
    }
    
    @IBOutlet weak var mapView: MKMapView!{
        didSet {
            mapView.mapType = .standard
            mapView.delegate = self
            if adventureId == nil {
                moveToCurrentLocation()
            }
        }
    }
    
    private func panToUserLocation(center: CLLocation) {
            let region = MKCoordinateRegion(center: center.coordinate, span: MKCoordinateSpanMake(0.05, 0.05) )
            mapView.setRegion(region, animated: true)
    }
    
    private func updateMapUI() {
        print("UPDATING")
        clearWaypoints()
        if adventure != nil {
            addWaypoints(waypoints: adventure!.markers)
        }
    }
    
    private func selectMarker(marker: Marker?) {
        if marker != nil {
            mapView.selectAnnotation(marker!, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let press = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(_:)))
        press.delegate = self
        
        mapView.addGestureRecognizer(press)
        
        waypointToolbar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Style Navbar
        TransparentUINavigationController().navBarTransparent(controller: self.navigationController!)
    }
    
    @objc private func addAnnotation(_ sender: UILongPressGestureRecognizer){
        if adventure != nil {
            if sender.state == .began {
                let coordinate = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
                let waypoint = Marker()
                waypoint.latitude = coordinate.latitude
                waypoint.longitude = coordinate.longitude
                waypoint.title = "Dropped"
                appendOrInsertAnnotation(waypoint, gesture: sender)
                updateMapUI()
            }
        }
    }
    
    private func appendOrInsertAnnotation(_ annotation: Marker, gesture: UILongPressGestureRecognizer) {
        if let direction = handleTap(gesture), let adv = adventure, let index = adv.markers.index(of: direction.start) {
            adv.markers.insert(annotation, at: index + 1)
        } else {
            adventure?.markers.append(annotation)
        }
    }
    
    func removeAnnotation(_ annotation: Marker) {
        if let adv = adventure, let index = adv.markers.index(of: annotation) {
            print("INDEX OF: \(index)")
            
            mapView.removeAnnotation(annotation)
            adv.markers.remove(at: index)
        }
        
    }
    
    private var directionLines = [MKPolyline]()
    
    func drawDirections() {
        print("DRAW DIRECTIONS BEING CALLED")
        if adventure != nil {
            mapView?.removeOverlays(directionLines)
            directionLines = []
            for direction in adventure!.directions {
                directionLines.append(direction.route!.polyline)
                //mapView.add(direction.route!.polyline, level: .aboveRoads)
            }
            mapView.addOverlays(directionLines, level: .aboveRoads)
        }
    }
    
    @IBAction func saveAdventure(_ sender: UIButton) {
        if let adv = adventure {
            if adv.markers.count > 0 {
                Adventure.postAdventure(adv: adv) { [weak weakself = self] adv in
                    weakself?.adventure = adv
                }
            } else {
                print("HAVEN'T MADE ANYTHING YET")
            }
        }
    }
    
    @IBAction func tapCurrentLocation(_ sender: UIButton) {
        moveToCurrentLocation()
    }
    
    private func clearWaypoints() {
        mapView?.removeAnnotations(mapView.annotations)
    }
    
    private func addWaypoints(waypoints: [Marker]) {
        mapView?.addAnnotations(waypoints)
        mapView?.showAnnotations(waypoints, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var view: MKAnnotationView! = mapView.dequeueReusableAnnotationView(withIdentifier: Identifiers.waypoint)
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Identifiers.waypoint)
            view.canShowCallout = true
        } else {
            view.annotation = annotation
        }
        
        view.isDraggable = true
        view.setSelected(true, animated: true)
        
        view.leftCalloutAccessoryView = nil
        view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        return view
    }
    
    
    private func distanceOfPoint(_ pt: MKMapPoint, to route: MKPolyline) -> Double{
        var distance = Double(MAXFLOAT)
        for i in 1..<route.pointCount {
            let ptA = route.points()[i-1]
            let ptB = route.points()[i]
            let xDelta = ptB.x - ptA.x
            let yDelta = ptB.y - ptA.y
            if xDelta == 0.0 && yDelta == 0.0 {
                continue
            }
            
            let u = ((pt.x - ptA.x) * xDelta + (pt.y - ptA.y) * yDelta) / (xDelta * xDelta + yDelta * yDelta)
            var ptClosest: MKMapPoint?
            
            if u < 0.0 {
                ptClosest = ptA
            } else if (u > 1.0) {
                ptClosest = ptB
            } else {
                ptClosest = MKMapPointMake(ptA.x + u * xDelta, ptA.y + u * yDelta)
            }
            
            distance = min(distance, MKMetersBetweenMapPoints(ptClosest!, pt))
            
        }
        return distance
    }
    
    private func metersFromPixel(_ px: Int, pt: CGPoint) -> Double {
        let ptB = CGPoint(x: pt.x + CGFloat(px), y: pt.y)
        
        let coordA = mapView.convert(pt, toCoordinateFrom: mapView)
        let coordB = mapView.convert(ptB, toCoordinateFrom: mapView)
        
        return MKMetersBetweenMapPoints(MKMapPointForCoordinate(coordA), MKMapPointForCoordinate(coordB))
    }
    
    private func handleTap(_ tap:UILongPressGestureRecognizer) -> Direction?{
        let touchPt = tap.location(in: mapView)
        let coord = mapView.convert(touchPt, toCoordinateFrom: mapView)
        
        let maxMeters = metersFromPixel(12, pt: touchPt)
        
        var nearestDistance = Double(MAXFLOAT)
        
        var nearestDirection: Direction?
        
        for direction in adventure?.directions ?? [] {
            if let polyline = direction.route?.polyline {
                let distance = distanceOfPoint(MKMapPointForCoordinate(coord), to: polyline)
                
                if distance < nearestDistance {
                    nearestDistance = distance
                    nearestDirection = direction
                }
            }
        }
        
        if nearestDistance <= maxMeters {
            return nearestDirection
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        view.setSelected(true, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        dismissToolbar()
        view.isSelected = true }
    
    // Renders the map route
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("RENDERING>>>>>>>>>>>>")
        if let overlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: overlay)
            
            print("CIRCLE FACTS: ")
            print("RADIUS: \(overlay.radius)")
            print("LOCATION: \(overlay.coordinate.latitude)")
            
            circleRenderer.fillColor = UIColor.blue
            circleRenderer.alpha = 0.1
            print("TRYING CIRCLE>>>>>")
            return circleRenderer
        }
        print("ACTUALLY A LINE")
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        
        return renderer
    }
    
    @IBAction func updatedMarker(segue: UIStoryboardSegue) {
        print(">>>>>>>>>ACTUALLY CALLED")
        selectMarker(marker: (segue.source.contentViewController as? WaypointPopoverViewController)?.waypointToEdit)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let annotationView = sender as? MKAnnotationView
        mapView.deselectAnnotation(annotationView?.annotation!, animated: true)
        let marker = annotationView?.annotation as? Marker
        let destination = segue.destination.contentViewController
        
        if segue.identifier == Identifiers.editMarkerPopoverSegue {
            if let editableWaypoint = marker, let ewvc = destination as? WaypointPopoverViewController {
                ewvc.waypointToEdit = editableWaypoint
                ewvc.deleteWaypointHook = removeAnnotation
            }
        } else if segue.identifier == Identifiers.editAdventureScreenShareAdventure {
            if let viewController = segue.destination as? AdventureShareViewController {
                viewController.adventure = adventure
                viewController.creator = appDelegate.authentication.currentUser
                viewController.additionalDismissalActions = dismissSelf
            }
        }
    }
    
    private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
    
//    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
//        selectMarker(marker: (popoverPresentationController.presentedViewController as? WaypointPopoverViewController)?.waypointToEdit)
//    }
    
//    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
//        if style == .fullScreen || style == .overFullScreen {
//            let navcon = UINavigationController(rootViewController: controller.presentedViewController)
//            let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
//            visualEffectView.frame = navcon.view.bounds
//            visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//            navcon.view.insertSubview(visualEffectView, at: 0)
//            return navcon
//        } else {
//            return nil
//        }
//    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            mapView.deselectAnnotation(view.annotation, animated: true)
            performSegue(withIdentifier: Identifiers.editMarkerPopoverSegue, sender: view)
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
    }
    
    @IBOutlet weak var waypointToolbar: UIView!
    
    @IBOutlet weak var showDirectionsButton: UIButton!
    @IBOutlet weak var showBeaconButton: UIButton!
    @IBOutlet weak var showNameButton: UIButton!
    @IBOutlet weak var showNoteButton: UIButton!
    @IBOutlet weak var deleteWaypointButton: UIButton!
    
    var pinchGestureRecognizer: UIPinchGestureRecognizer?
    
    var waypointToEdit: Marker? {
        didSet {
            if waypointToEdit != nil {
                updateUI()
            }
        }
    }
    
    let defaultRange = 25
    
    var circle: MKCircle?
    
    var currentlyEditing: ActionItem = .none
    
    enum ActionItem {
        case directions
        case beacon
        case name
        case note
        case none
    }
    
    var noteView = UITextView()
    var noteObserver: NSObjectProtocol?
}

extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? navcon
        } else {
            return self
        }
    }
}
