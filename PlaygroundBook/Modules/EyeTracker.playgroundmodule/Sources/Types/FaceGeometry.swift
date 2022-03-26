//
//  FaceGeometry.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/4/22.
//

import CoreGraphics

struct FaceGeometry {
    let boundingBox: CGRect
    /// Face tilt ↶↷
    let roll: Double
    /// Face position ↕︎
    let pitch: Double
    /// Face position ↔︎
    let yaw: Double
}
