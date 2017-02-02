//
//  WaypointRangeElements.swift
//  Spool
//
//  Created by Matthew Slotkin on 2/2/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation
import MapKit

class RangeElement: MKCircle {
    func renderer(color: UIColor) -> MKCircleRenderer {
        let renderer = MKCircleRenderer(circle: self)
        renderer.fillColor = color
        renderer.alpha = 0.1
        return renderer
    }
}

class BeaconRangeElement: RangeElement {
    func renderer() -> MKCircleRenderer {
        return renderer(color: UIColor.orange)
    }
}

class NameRangeElement: RangeElement {
    func renderer() -> MKCircleRenderer {
        return renderer(color: UIColor.green)
    }
}

class NoteRangeElement: RangeElement {
    func renderer() -> MKCircleRenderer {
        return renderer(color: UIColor.purple)
    }
}
