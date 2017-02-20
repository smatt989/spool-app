//
//  AdventureEditingViewController.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/9/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit
import MapKit

class AdventureEditingViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, UITextViewDelegate, UITextFieldDelegate {
    
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
        editingWaypoint = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Style Navbar
        if let navController = navigationController {
            TransparentUINavigationController().navBarTransparent(controller: navController)
        }
    }
    
    @objc private func addAnnotation(_ sender: UILongPressGestureRecognizer){
        if adventure != nil {
            if sender.state == .began {
                let coordinate = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
                let waypoint = Marker()
                waypoint.latitude = coordinate.latitude
                waypoint.longitude = coordinate.longitude
                waypoint.title = defaultNameText
                appendOrInsertAnnotation(waypoint, gesture: sender)
                updateMapUI()
                selectMarker(marker: waypoint)
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
    
    private func removeAnnotation(_ annotation: Marker) {
        if let adv = adventure, let index = adv.markers.index(of: annotation) {
            mapView.removeAnnotation(annotation)
            adv.markers.remove(at: index)
        }        
    }
    
    private func drawDirections() {
        if adventure != nil {
            mapView?.removeOverlays(mapView.overlays.filter{ overlay in overlay is MKPolyline})
            
            let directionsToDraw = adventure!.directions.filter{
                $0.end.showDirections
            }
            
            for direction in directionsToDraw {
                mapView.add(direction.route!.polyline, level: .aboveRoads)
            }
        }
    }
    
//    private let transformConstant = 1 / 500.0
//    
//    private var arrowViews = [UIImageView]()
//    
//    private func drawDirectionArrows() {
//        arrowViews.forEach{
//            $0.removeFromSuperview()
//        }
//        arrowViews = [UIImageView]()
//        if adventure != nil {
//            for direction in adventure!.directions {
//                let route = direction.route!.polyline
//                let pointCount = route.pointCount
//                for i in 1 ..< pointCount {
//                    print(">>>>>>>>>>>>DRAWING<<<<<<<<<<<<")
//                    let thisPoint = route.points()[i]
//                    let lastPoint = route.points()[i - 1]
//                    let img = #imageLiteral(resourceName: "small-arrow")
//                    
//                    let width = CGFloat(30)
//                    let height = CGFloat(20)
//                    
//                    let imgView = UIImageView(image: img.imageResize(sizeChange: CGSize(width: width, height: height)))
//                    
//                    let currentCoordinate = MKCoordinateForMapPoint(thisPoint)
//                    let previousCoordinate = MKCoordinateForMapPoint(lastPoint)
//                    let currentCGPoint = mapView.convert(currentCoordinate, toPointTo: mapView)
//                    let previousCGPoint = mapView.convert(previousCoordinate, toPointTo: mapView)
//
//                    
//                    let xDiff = currentCGPoint.x - previousCGPoint.x
//                    let yDiff = -(currentCGPoint.y - previousCGPoint.y)
//                    let angle = tan(xDiff / yDiff)
//                    
//                    var transform = CATransform3DIdentity
//                    transform.m34 = CGFloat(transformConstant)
//                    
//                    imgView.layer.transform = CATransform3DRotate(transform, angle, 0, 0, 1)
//                    
//                    imgView.frame = CGRect(x: currentCGPoint.x - (width / 2), y: currentCGPoint.y - (height / 2), width: width, height: height)
//                    
//                    arrowViews.append(imgView)
//                }
//            }
//        }
//        arrowViews.forEach{
//            view.addSubview($0)
//        }
//        
//    }
    
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
    
    private let pinHeight = CGFloat(39.0)
    
    enum MarkerState {
        case normal
        case highlighted
        case beacon
    }
    
    private func pinViewFromState(_ state: MarkerState) -> UIImage {
        var image: UIImage?
        var width: CGFloat
        var height: CGFloat
        
        switch state{
        case .normal:
            image = #imageLiteral(resourceName: "marker")
            width = 39.0
            height = 40.0
        case .highlighted:
            image = #imageLiteral(resourceName: "selected_marker")
            width = 50.0
            height = 52.0
        case .beacon:
            image = #imageLiteral(resourceName: "starshot")
            width = 50.0
            height = 52.0
        }
        
        image = image!.imageResize(sizeChange: CGSize(width: width, height: height))
        return image!
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var view: MKAnnotationView! = mapView.dequeueReusableAnnotationView(withIdentifier: Identifiers.waypoint)
        if view == nil {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: Identifiers.waypoint)
            view.canShowCallout = false
        } else {
            view.annotation = annotation
        }

        view.image = pinViewFromState(.normal)
        view.centerOffset = CGPoint(x: 0, y: view.image!.size.height / -2.0)
        
        view.isDraggable = true
        view.setSelected(true, animated: true)
        
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
        
        if newState == MKAnnotationViewDragState.starting {
            view.dragState = MKAnnotationViewDragState.dragging
        }
        else if newState == MKAnnotationViewDragState.ending || newState == MKAnnotationViewDragState.canceling {
            view.dragState = MKAnnotationViewDragState.none;
        }

        view.setSelected(true, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        editingWaypoint = nil
        view.isSelected = true
        unhighlightPin(view)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        editingWaypointView = view
        editingWaypoint = view.annotation as? Marker
        //focusPin(view)
    }
    
    private func focusPin(_ view: MKAnnotationView) {
        if editingWaypoint?.showBeaconWithinMeterRange != nil {
            makeBeaconPin(view)
        } else {
            highlightPin(view)
        }
    }
    
    private func makeBeaconPin(_ view: MKAnnotationView) {
        view.image = pinViewFromState(.beacon)
    }
    
    private func highlightPin(_ view: MKAnnotationView){
        view.image = pinViewFromState(.highlighted)
    }
    
    private func unhighlightPin(_ view: MKAnnotationView) {
        view.image = pinViewFromState(.normal)
    }
    
    // Renders the map route
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? BeaconRangeElement {
            return overlay.renderer()
        }
        if let overlay = overlay as? NameRangeElement {
            return overlay.renderer()
        }
        if let overlay = overlay as? NoteRangeElement {
            return overlay.renderer()
        }
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red: 0.48, green: 0.54, blue: 0.92, alpha: 1.0) // #7A89EB
        renderer.lineWidth = 6.0
        
        return renderer
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let annotationView = sender as? MKAnnotationView
        mapView.deselectAnnotation(annotationView?.annotation!, animated: true)
        
        if segue.identifier == Identifiers.editAdventureScreenShareAdventure {
            if let viewController = segue.destination as? AdventureShareViewController {
                viewController.adventure = adventure
                viewController.creator = appDelegate.authentication.currentUser
                viewController.additionalDismissalActions = dismissSelf
            }
        }
    }
    
    private func dismissSelf() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            mapView.deselectAnnotation(view.annotation, animated: true)
            performSegue(withIdentifier: Identifiers.editMarkerPopoverSegue, sender: view)
        }
    }
    
    @IBOutlet weak var saveAdventureButton: RoundedUIButton!
    @IBOutlet weak var waypointToolbar: UIView!
    
    @IBOutlet weak var navigationToggleButton: ToolbarButton!
    @IBOutlet weak var beaconToggleButton: ToolbarButton!
    @IBOutlet weak var nameToggleButton: ToolbarButton!
    @IBOutlet weak var noteToggleButton: ToolbarButton!
    @IBOutlet weak var deleteWaypointButton: ToolbarButton!

    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var noteInput: UITextView!
    
    
    private var toolbarButtons: [ToolbarButton] {
        get {
            return [
                navigationToggleButton,
                beaconToggleButton,
                nameToggleButton,
                noteToggleButton,
                deleteWaypointButton
            ]
        }
    }
    
    private var editingWaypoint: Marker? {
        didSet {
            if editingWaypoint != nil {
                showToolbar()
            } else {
                hideToolbar()
                editingWaypointView = nil
            }
        }
    }
    
    private var editingWaypointView: MKAnnotationView?
    
    private func showToolbar() {
        setAllToolbarButtonsToNotFocused()
        updateWaypointToolbarUI()
        setupKeyboards()
        waypointToolbar.isHidden = false
        saveAdventureButton.isHidden = false
        startListening()
        addDisplayLink()
    }
    
    private func hideToolbar() {
        stopListening()
        removeDisplayLink()
        nameView.isHidden = true
        noteInput.isHidden = true
        waypointToolbar.isHidden = true
        removePinchGesture()
        dismissKeyboard()
        saveAdventureButton.isHidden = false
    }
    
    @IBAction func navigationToggleTap(_ sender: ToolbarButton) {
        editingWaypoint!.showDirections = !editingWaypoint!.showDirections
        setAllToolbarButtonsToNotFocused()
        updateWaypointToolbarUI()
    }

    private let defaultPointRange = 50
    private let defaultNameText = "Dropped"
    
    private func defaultMeterRange() -> Int {
        let waypointPoint = mapView.convert((editingWaypoint!.coordinate), toPointTo: mapView)
        let pointRadiusAway = CGPoint(x: waypointPoint.x + CGFloat(defaultPointRange), y: waypointPoint.y)
        let newCoordinate = mapView.convert(pointRadiusAway, toCoordinateFrom: mapView)
        let distance = CLLocation(latitude: editingWaypoint!.latitude, longitude: editingWaypoint!.longitude).distance(from: CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude))
        return Int(round(distance))
    }
    
    @IBAction func beaconToggleTap(_ sender: ToolbarButton) {
        if sender.isFocus && sender.isOn {
            editingWaypoint!.showBeaconWithinMeterRange = nil
        } else {
            editingWaypoint!.showBeaconWithinMeterRange = editingWaypoint!.showBeaconWithinMeterRange ?? defaultMeterRange()
        }
        tapButton(sender)
        updateWaypointToolbarUI()
    }
    
    @IBAction func nameToggleTap(_ sender: ToolbarButton) {
        if sender.isFocus && sender.isOn {
            editingWaypoint!.showNameWithinMeterRange = nil
        } else {
            editingWaypoint!.showNameWithinMeterRange = editingWaypoint!.showNameWithinMeterRange ?? defaultMeterRange()
        }
        tapButton(sender)
        updateWaypointToolbarUI()
    }

    @IBAction func noteToggleTap(_ sender: ToolbarButton) {
        if sender.isFocus && sender.isOn {
            editingWaypoint!.showDescriptionWithinMeterRange = nil
            editingWaypoint!.descriptionText = nil
        } else {
            editingWaypoint!.showDescriptionWithinMeterRange = editingWaypoint!.showDescriptionWithinMeterRange ?? defaultMeterRange()
        }
        tapButton(sender)
        updateWaypointToolbarUI()
    }
    
    @IBAction func deleteWaypointTap(_ sender: ToolbarButton) {
        setAllToolbarButtonsToNotFocused()
        removeAnnotation(editingWaypoint!)
        editingWaypoint = nil
        drawRanges()
    }
    
    private func tapButton(_ button: ToolbarButton) {
        setAllToolbarButtonsToNotFocused()
        button.isFocus = true
    }
    
    private func setAllToolbarButtonsToNotFocused() {
        toolbarButtons.forEach{button in
            button.isFocus = false
        }
    }
    
    private func updateWaypointToolbarUI() {
        setButtonActivation()
        setWaypointMetadataVisibility()
        moveWaypointMetadataViews()
        establishFirstResponder()
        injectPinchGesture()
        drawRanges()
    }
    
    private func setupKeyboards() {
        noteInput.returnKeyType = .done
        noteInput.delegate = self
        nameInput.returnKeyType = .done
        nameInput.delegate = self
        nameInput.autocorrectionType = UITextAutocorrectionType.no
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    private func setButtonActivation() {
        navigationToggleButton.isOn = editingWaypoint!.showDirections
        beaconToggleButton.isOn = editingWaypoint!.showBeaconWithinMeterRange != nil
        nameToggleButton.isOn = editingWaypoint!.showNameWithinMeterRange != nil
        noteToggleButton.isOn = editingWaypoint!.showDescriptionWithinMeterRange != nil
    }
    
    private func setWaypointMetadataVisibility() {
        nameView.isHidden = editingWaypoint!.showNameWithinMeterRange == nil
        noteInput.isHidden = editingWaypoint!.showDescriptionWithinMeterRange == nil
        nameInput.text = editingWaypoint!.title
        noteInput.text = editingWaypoint!.descriptionText
        focusPin(editingWaypointView!)
    }
    
    @objc private func moveWaypointMetadataViews() {
        if editingWaypoint != nil {
            moveNoteInput()
            moveNameView()
        }
    }
    
    private func moveNoteInput() {
        
        let leadingSpace:CGFloat = 20.0
        let trailingSpace:CGFloat = 20.0
        let height = noteInput.frame.height
        let width = view.frame.maxX - trailingSpace - leadingSpace
        
        if noteInput.isFirstResponder {
            noteInput.frame = CGRect(x: leadingSpace, y: 350, width: width, height: height)
        } else {
            noteInput.frame = CGRect(x: leadingSpace, y: view.frame.maxY - height - 155, width: width, height: height)
        }
    }
    
    private func moveNameView() {
        let position = mapView.convert(editingWaypoint!.coordinate, toPointTo: view)
        let nameHeight = nameView.layer.frame.height
        let nameWidth = nameView.layer.frame.width
        
        let buffer = CGFloat(5.0)
        
        var attemptedHeight = position.y - nameHeight - buffer - pinHeight
        if !noteInput.isHidden && noteInput.frame.minY < (attemptedHeight + nameHeight + buffer + pinHeight) {
            attemptedHeight = noteInput.frame.minY - nameHeight - buffer - pinHeight
        }
        
        nameView.frame = CGRect(x: position.x - (nameWidth / 2), y: attemptedHeight, width: nameWidth, height: nameHeight)
    }
    
    var moveViewsDisplayLink: CADisplayLink?
    
    private func addDisplayLink() {
        let moveViewsDisplayLink = CADisplayLink(target: self, selector: #selector(moveWaypointMetadataViews))
        moveViewsDisplayLink.add(to: .main, forMode: .commonModes)
    }
    
    private func removeDisplayLink() {
        if moveViewsDisplayLink != nil {
            moveViewsDisplayLink!.remove(from: .main, forMode: .commonModes)
        }
    }
    
    private func establishFirstResponder() {
        view.endEditing(true)
        if !nameView.isHidden && editingWaypoint!.title == defaultNameText && nameToggleButton.isFocus {
            nameInput.becomeFirstResponder()
            nameInput.text = ""
        } else if !noteInput.isHidden && editingWaypoint!.descriptionText == nil && noteToggleButton.isFocus {
            noteInput.becomeFirstResponder()
        }
    }
    
    private var nameObserver: NSObjectProtocol?
    private var noteObserver: NSObjectProtocol?
    
    private func startListening() {
        let center = NotificationCenter.default
        let queue = OperationQueue.main
        
        nameObserver = center.addObserver(
            forName: Notification.Name.UITextFieldTextDidChange,
            object: nameInput,
            queue: queue) { [weak weakself = self] notification in
                if AdventureUtilities.validTitle(title: weakself?.nameInput.text) {
                    weakself?.editingWaypoint!.title = weakself?.nameInput.text
                }
            }
        
        noteObserver = center.addObserver(
            forName: Notification.Name.UITextViewTextDidChange,
            object: noteInput,
            queue: queue) { [weak weakself = self] notification in
                if AdventureUtilities.validTitle(title: weakself?.noteInput.text) {
                    weakself?.editingWaypoint!.descriptionText = weakself?.noteInput.text
                } else {
                    weakself?.editingWaypoint!.descriptionText = nil
                }
            }
    }
    
    private func stopListening() {
        if let observer = nameObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        if let observer = noteObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nameButtonFocusTriggeredByInputTouch()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        noteButtonFocusTriggeredByInputTouch()
    }
    
    private func nameButtonFocusTriggeredByInputTouch() {
        if nameInput.isFirstResponder {
                tapButton(nameToggleButton)
        }
    }
    
    private func noteButtonFocusTriggeredByInputTouch() {
        if noteInput.isFirstResponder {
            tapButton(noteToggleButton)
        }
    }
    
    private var pinchGestureRecognizer: UIPinchGestureRecognizer?
    
    private func injectPinchGesture() {
        if (toolbarButtons.filter{ $0.isOn && $0.isFocus }).count > 0 {
            addPinchGesture()
        } else {
            removePinchGesture()
        }
    }
    
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
        if pinchGestureRecognizer != nil {
            mapView.removeGestureRecognizer(pinchGestureRecognizer!)
        }
    }
    
    @objc
    func pinchedView(_ sender:UIPinchGestureRecognizer){
        if beaconToggleButton.isFocus && editingWaypoint!.showBeaconWithinMeterRange != nil {
            editingWaypoint!.showBeaconWithinMeterRange! = Int(round(Double(sender.scale) * Double(editingWaypoint!.showBeaconWithinMeterRange!)))
        } else if nameToggleButton.isFocus && editingWaypoint!.showNameWithinMeterRange != nil {
            editingWaypoint!.showNameWithinMeterRange! = Int(round(Double(sender.scale) * Double(editingWaypoint!.showNameWithinMeterRange!)))
        } else if noteToggleButton.isFocus && editingWaypoint!.showDescriptionWithinMeterRange != nil {
            editingWaypoint!.showDescriptionWithinMeterRange! = Int(round(Double(sender.scale) * Double(editingWaypoint!.showDescriptionWithinMeterRange!)))
        }
        sender.scale = 1.0
        drawRanges()
    }
    
    private func drawRanges() {
        drawBeaconRanges()
        drawNameRanges()
        drawNoteRanges()
        drawDirections()
    }
    
    private var beaconRanges = [BeaconRangeElement]()
    private var nameRanges = [NameRangeElement]()
    private var noteRanges = [NoteRangeElement]()
    
    private func drawBeaconRanges() {
        mapView.removeOverlays(beaconRanges)
        beaconRanges = (adventure?.markers ?? []).flatMap{element in
            if let range = element.showBeaconWithinMeterRange {
                return BeaconRangeElement(center: element.coordinate, radius: CLLocationDistance(range))
            } else {
                return nil
            }
        }
        mapView.addOverlays(beaconRanges)
    }
    
    private func drawNameRanges() {
        mapView.removeOverlays(nameRanges)
        nameRanges = (adventure?.markers ?? []).flatMap{element in
            if let range = element.showNameWithinMeterRange {
                return NameRangeElement(center: element.coordinate, radius: CLLocationDistance(range))
            } else {
                return nil
            }
        }
        mapView.addOverlays(nameRanges)
    }
    
    private func drawNoteRanges() {
        mapView.removeOverlays(noteRanges)
        noteRanges = (adventure?.markers ?? []).flatMap{element in
            if let range = element.showDescriptionWithinMeterRange {
                return NoteRangeElement(center: element.coordinate, radius: CLLocationDistance(range))
            } else {
                return nil
            }
        }
        mapView.addOverlays(noteRanges)
    }

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

extension UIImage {
    
    func imageResize (sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }
    
}
