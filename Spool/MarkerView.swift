//
//  MarkerView.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/12/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

protocol MarkerViewDelegate {
    func didTouchMarkerView(_ markerView:MarkerView)
}


class MarkerView : UIView {
    var coordinate:ARGeoCoordinate!
    var delegate:MarkerViewDelegate?
    var distanceLabel:UILabel?
    let kWidth:CGFloat = 200.0
    let kHeight:CGFloat = 100.0
    
    override init(frame: CGRect) {
        super.init(frame : frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(_coordinate:ARGeoCoordinate, _delegate:MarkerViewDelegate) {
        let frame = CGRect(x: 0, y: 0, width: kWidth, height: kHeight)
        super.init(frame: frame)
        
        self.coordinate = _coordinate
        self.delegate = _delegate
        
        self.isUserInteractionEnabled = true
        
        let titleFrame:CGRect = CGRect(x: 0, y: 0, width: kWidth, height: 40.0)
        
        let title:UILabel = UILabel(frame: titleFrame)
        title.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
        title.textColor = UIColor.white
        title.textAlignment = NSTextAlignment.center
        title.text = self.coordinate!.title
        title.sizeToFit()
        
        let distanceFrame:CGRect = CGRect(x: 0, y: 45.0, width: kWidth, height: 40.0)
        
        self.distanceLabel = UILabel(frame: distanceFrame)
        self.distanceLabel!.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
        self.distanceLabel!.textColor = UIColor.white
        self.distanceLabel!.textAlignment = NSTextAlignment.center
        updateDistanceLabel()
        self.distanceLabel!.sizeToFit()
        
        self.addSubview(title)
        self.addSubview(self.distanceLabel!)
        
        self.backgroundColor = UIColor.clear
    }
    
    func updateDistanceLabel() {
        distanceLabel!.text = String(format: "%.6f", coordinate!.distanceFromOrigin / 1000.0) + "km"
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        updateDistanceLabel()
        //self.distanceLabel!.text = String(format: "%.2f", self.coordinate!.distanceFromOrigin / 1000.0) + "km"
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with e: UIEvent?) {
        self.delegate?.didTouchMarkerView(self)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let theFrame = CGRect(x: 0, y: 0, width: kWidth, height: kHeight)
        
        return theFrame.contains(point)
    }
    
}
