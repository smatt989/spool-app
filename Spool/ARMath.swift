//
//  ARMath.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/17/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation
import CoreMotion
import CoreLocation

class ARMath {
    
    
    // can do 2 approaches:
    //  1) inputs gravity, heading, current location and destination, outputs an orientation of the device relative to that destiantion
    //  2) given an intial gravity and initial heading, inputs attitude (relative to that initial orientation), current location and destionation, outputs an orientation of the device relative to that desetination (may be more smooth than the first approach)
    
    
    //need to deal with altitude eventually
    static func relativeOrientationOf(deviceOrientation: DeviceOrientation, at currentLocation: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> CustomAttitude {
        let absoluteRadialDistanceBetweenLocations = preciseRadialDistanceBetween(currentLocation, and: destination)
        //print("absolute radial distance \(absoluteRadialDistanceBetweenLocations)")
        let relativeRadialDistanceGivenHeading = radialDifferenceBetween(heading: deviceOrientation.heading, and: absoluteRadialDistanceBetweenLocations)
        //print("relative radial distance \(relativeRadialDistanceGivenHeading)")
        
        let gravityZAngle = asin(deviceOrientation.gravity.z)
        let gravityXAngle = asin(deviceOrientation.gravity.x)
        
        return CustomAttitude(pitch: gravityZAngle, yaw: gravityXAngle, roll: relativeRadialDistanceGivenHeading)
        
        
//        let gravityPoint = Point3D(x: deviceOrientation.gravity.x, y: deviceOrientation.gravity.y, z: deviceOrientation.gravity.z)
//        let gravityPointRotatedOnXAxis = gravityPoint.rotate(radians: 1.5 * M_PI, axis: .x)
//        
//        let gravityXAngle = asin(deviceOrientation.gravity.x)
//        let gravityYAngle = asin(deviceOrientation.gravity.y)
//        let gravityZAngle = asin(deviceOrientation.gravity.z)
//        
//        let xGravityDiff = gravityXAngle
    }
    
//    static func relativeOrientationOf(initialOrientation: DeviceOrientation, absoluteOrientation: CMAttitude, heading: CLLocationDirection, absoluteLocation: CLLocation, to: CLLocation) {
//        let absoluteRadialDistanceBetweenLocations = preciseRadialDistanceBetween(absoluteLocation.coordinate, and: to.coordinate)
//        let relativeRadialDistanceGivenHeading = radialDifferenceBetween(heading: heading, and: absoluteRadialDistanceBetweenLocations)
//        
//        let gravityXAngle = asin(initialOrientation.initialGravity.x)
//        let gravityYAngle = asin(initialOrientation.initialGravity.y)
//        let gravityZAngle = asin(initialOrientation.initialGravity.z)
//    }
    
    static func preciseRadialDistanceBetween(_ source: CLLocationCoordinate2D, and: CLLocationCoordinate2D) -> Double {
        let lat1 = radiansFromDegrees(source.latitude)
        let lat2 = radiansFromDegrees(and.latitude)
        let lng1 = radiansFromDegrees(source.longitude)
        let lng2 = radiansFromDegrees(and.longitude)
        
        let y = sin(lng2 - lng1) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lng2 - lng1)
        let result = atan2(y, x)//).truncatingRemainder(dividingBy: 2 * M_PI)
        return result
    }
    
    static func radialDifferenceBetween(heading: CLLocationDirection, and radialOffset: Double) -> Double {
        //print("heading: degrees: \(heading) radians: \(radiansFromDegrees(heading))")
        return radiansAdjustmentToNegPiToPiSpace(radians: radiansFromDegrees(heading) - radialOffset)
    }
    
    static func radiansFromDegrees(_ degrees: Double) -> Double {
        return degrees * M_PI / 180
    }
    
    static func degreesFromRadians(_ radians: Double) -> Double {
        return radians * 180 / M_PI
    }
    
    static func radiansAdjustmentToNegPiToPiSpace(radians: Double) -> Double {
        let scaledCorrectly = radians.truncatingRemainder(dividingBy: 2 * M_PI)
        if scaledCorrectly < -M_PI {
            return scaledCorrectly + 2 * M_PI
        } else if scaledCorrectly > M_PI {
            return scaledCorrectly - 2 * M_PI
        } else {
            return scaledCorrectly
        }
    }

}

protocol Attitude {
    var pitch: Double { get }
    var yaw: Double { get }
    var roll: Double { get }
}

class CustomAttitude: Attitude {
    var pitch: Double
    var yaw: Double
    var roll: Double
    
    init(pitch: Double, yaw: Double, roll: Double) {
        self.pitch = pitch
        self.yaw = yaw
        self.roll = roll
    }
}

extension CMAttitude: Attitude {
    
}

struct Point3D {
    var x: Double
    var y: Double
    var z: Double
    
    func rotate(radians: Double, axis: RotationAxis) -> Point3D {
        switch axis {
        case .x:
            let rotationMatrix = Point3D.generateRotationMatrixOnXAxis(radians: radians)
            return multiplyRotationMatrix(rotationMatrix: rotationMatrix)
        case .y:
            let rotationMatrix = Point3D.generateRotationMatrixOnYAxis(radians: radians)
            return multiplyRotationMatrix(rotationMatrix: rotationMatrix)
        case .z:
            let rotationMatrix = Point3D.generateRotationMatrixOnZAxis(radians: radians)
            return multiplyRotationMatrix(rotationMatrix: rotationMatrix)
        }
    }
    
    enum RotationAxis {
        case x
        case y
        case z
    }
    
    private func multiplyRotationMatrix(rotationMatrix: CMRotationMatrix) -> Point3D {
        let newX = x * rotationMatrix.m11 + y * rotationMatrix.m12 + z * rotationMatrix.m13
        let newY = x * rotationMatrix.m21 + y * rotationMatrix.m22 + z * rotationMatrix.m23
        let newZ = x * rotationMatrix.m31 + y * rotationMatrix.m32 + z * rotationMatrix.m33
        return Point3D(x: newX, y: newY, z: newZ)
    }
    
    static func generateRotationMatrixOnXAxis(radians: Double) -> CMRotationMatrix {
        return CMRotationMatrix(m11: 1, m12: 0, m13: 0, m21: 0, m22: cos(radians), m23: -sin(radians), m31: 0, m32: sin(radians), m33: cos(radians))
    }
    
    static func generateRotationMatrixOnYAxis(radians: Double) -> CMRotationMatrix {
        return CMRotationMatrix(m11: cos(radians), m12: 0, m13: sin(radians), m21: 0, m22: 1, m23: 0, m31: -sin(radians), m32: 0, m33: cos(radians))
    }
    
    static func generateRotationMatrixOnZAxis(radians: Double) -> CMRotationMatrix {
        return CMRotationMatrix(m11: cos(radians), m12: -sin(radians), m13: 0, m21: sin(radians), m22: cos(radians), m23: 0, m31: 0, m32: 0, m33: 1)
    }
}

struct DeviceOrientation {
    var gravity: CMAcceleration
    var heading: CLLocationDirection
}
