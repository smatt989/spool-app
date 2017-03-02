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
    var waypoint: Marker? { get set }
    var layer: CALayer { get }
    var indicator: CustomUIView { get }
    var indicatorSize: CGFloat { get }
}
