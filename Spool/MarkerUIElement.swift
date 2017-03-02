//
//  MarkerUIElement.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/25/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation
import UIKit

protocol MarkerUIElement {
    var layer: CALayer { get }
    var indicatorIcon: UIImage { get }
    
    func setup(outerFrame: CGRect, waypoint: Marker) -> Void
}
