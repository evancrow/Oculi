//
//  EyeTrackerModel.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/1/22.
//

import Combine
import CoreGraphics
import Vision
import SwiftUI

protocol EyeTrackerDelegate {
    func landmarksDidChange(_ landmarks: VNFaceLandmarks2D)
    func faceGeometryDidChange(_ geometry: FaceGeometry)
    func faceCaptureQualityDidChange(_ quality: QualityState)
}

public class EyeTrackerModel: ObservableObject {
    private var avModel: AVModel!
    private var visionModel: VisionModel!
    private var interactionManager: InteractionManager!

    @Published public private(set) var quality: QualityState = .noFaceDetected
    @Published public private(set) var isTracking = false
    var keyboardVisible = false
    public var paused: Bool {
        quality != .faceDetected || isBlinking || keyboardVisible
    }
    
    // Blinking states
    @Published public private(set) var isBlinking: Bool = false {
        didSet {
            if oldValue != isBlinking {
                blinkStateChanged()
            }
        }
    }
    private var currentBlinkDuration = 0
    private var currentNumberOfBlinks = 0
    
    // Blink timers
    private var blinkGroupTimer: Timer? = nil
    private var blinkDurationTimer: Timer? = nil
    
    // Offset + Movement
    @Published var offset: CGPoint = CGPoint(x: 0, y: 0) {
        didSet {
            interactionManager.onCursorOffsetChanged(boundingBox: getCursorBoundingBox())
        }
    }
    /// Geometry from when tracking first began, used as a baseline.
    private var originGeometry: FaceGeometry? = nil
    private var height: CGFloat = 0
    private var width: CGFloat = 0
    
    // MARK: - Public Functions
    public func toggleTrackingState() {
        if isTracking {
            endTracking()
        } else {
            startTracking()
        }
    }
    
    public func resetOffset() {
        originGeometry = nil
        offset = CGPoint(x: 0, y: 0)
    }
    
    public func startTracking() {
        resetOffset()
        isTracking = true
    }
    
    public func endTracking() {
        isTracking = false
    }
    
    // MARK: - Blinking
    private func checkIfEyeIsBlinking(points: [CGPoint]) -> Bool {
        guard quality == .faceDetected, points.count == 6 else {
            return false
        }
        
        // Point layout (eye):
        // /-2-3-\
        // 1  •  4
        // \-6-5-/
        
        let p2 = points[1]
        let p3 = points[2]
        let p5 = points[4]
        let p6 = points[5]
        
        let leftHeight = p2.y - p6.y
        let rightHeight = p3.y - p5.y
        let threshold = UXDefaults.isBlinkingMargin

        return leftHeight < threshold && rightHeight < threshold
    }
    
    private func blinkStateChanged() {
        if isBlinking {
            // User blinked again very quickly,
            // should count this as another blink in the group.
            if let blinkGroupTimer = blinkGroupTimer, blinkGroupTimer.isValid, isTracking {
                currentNumberOfBlinks += 1
                blinkGroupTimer.invalidate()
            }
            
            blinkDurationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                self.currentBlinkDuration += 1
            }
        } else {
            longBlinkEnded()
            
            blinkDurationTimer?.invalidate()
            currentBlinkDuration = 0
            
            // User did not blink again in a close proximity to the last one.
            // Reset the group timer.
            blinkGroupTimer = Timer.scheduledTimer(
                withTimeInterval: UXDefaults.maximumBlinkSeperationTime,
                repeats: false, block: { _ in
                    self.blinksEnded()
                    self.blinkGroupTimer = nil
                    self.currentNumberOfBlinks = 0
            })
        }
    }
    
    private func longBlinkEnded() {
        let seconds = currentBlinkDuration + 1
        
        if seconds == UXDefaults.toggleTrackingBlinkDuration {
            toggleTrackingState()
        }
        
        interactionManager.onLongBlink(onLongBlink: (seconds, getCursorBoundingBox()))
    }
    
    // Called when the user stops blinking
    private func blinksEnded() {
        let numberOfBlinks  = currentNumberOfBlinks + 1
        interactionManager.onBlink(onBlink: (numberOfBlinks, getCursorBoundingBox()))
    }
    
    private func getCursorBoundingBox() -> CGRect {
        let originX = width / 2
        let originY = height / 2
        
        let currentX = originX + offset.x
        let currentY = originY + offset.y
        let offsetForMin = UXDefaults.cursorHeight / 2
        
        let boundingBox = CGRect(x: currentX - offsetForMin,
                                 y: currentY - offsetForMin,
                                 width: UXDefaults.cursorHeight,
                                 height: UXDefaults.cursorHeight)
        
        return boundingBox
    }
    
    // MARK: - Head Movement
    private func updateOffset(with geometry: FaceGeometry) {
        guard let originGeometry = originGeometry else {
            originGeometry = geometry
            return
        }

        let yaw = geometry.yaw
        let originYaw = originGeometry.yaw
        let xOffset: CGFloat = {
            if yaw > originYaw {
                return yaw - originYaw
            } else {
                return -(originYaw - yaw)
            }
        }()
        
        let pitch = geometry.pitch
        let originPitch = originGeometry.pitch
        let yOffset: CGFloat = {
            if pitch > originPitch {
                return pitch - originPitch
            } else {
                return -(originPitch - pitch)
            }
        }()
        
        let newXOffset = (xOffset * UXDefaults.movmentMultiplier.width)
        let newYOffset = (yOffset * UXDefaults.movmentMultiplier.height)
        
        if checkIfOffsetIsInBounds(CGPoint(x: newXOffset, y: newYOffset)) {
            withAnimation(.linear) {
                offset.x += newXOffset
                offset.y += newYOffset
            }
        }
    }
    
    private func checkIfOffsetIsInBounds(_ newOffset: CGPoint) -> Bool {
        let padding: CGFloat = 12
        
        // Positions relative to the global frame
        let expectedX = (width / 2) + offset.x + newOffset.x
        let expectedY = (height / 2) + offset.y + newOffset.y
        
        let withinX = expectedX < (width - padding) && expectedX > padding
        let withinY = expectedY < (height - padding) && expectedY > padding
     
        return withinX && withinY
    }
    
    // MARK: - config
    public func config(interactionManager: InteractionManager) {
        let visionModel = VisionModel(eyeTrackerDelegate: self)
        
        self.interactionManager = interactionManager
        self.avModel = AVModel(visionModel: visionModel)
        self.visionModel = visionModel
    }
    
    /// Should be called if camera permission state changes
    public func resetAVModel() {
        self.avModel.config()
    }
    
    public func updateViewValues(_ size: CGSize) {
        self.height = size.height
        self.width = size.width
    }
}

// MARK: - State Updates
extension EyeTrackerModel: EyeTrackerDelegate {
    func landmarksDidChange(_ landmarks: VNFaceLandmarks2D) {
        if let leftEyePoints = landmarks.leftEye?.normalizedPoints,
           let rightEyePoints = landmarks.rightEye?.normalizedPoints {
            
            let leftEyeBlinking = checkIfEyeIsBlinking(points: leftEyePoints)
            let rightEyeBlinking = checkIfEyeIsBlinking(points: rightEyePoints)
            
            // Don't update state if it's not necessary.
            if ((leftEyeBlinking && rightEyeBlinking) != isBlinking) {
                isBlinking = leftEyeBlinking && rightEyeBlinking
            }
        }
    }
    
    func faceGeometryDidChange(_ geometry: FaceGeometry) {
        guard isTracking, !paused else {
            return
        }
        
        updateOffset(with: geometry)
    }
    
    func faceCaptureQualityDidChange(_ quality: QualityState) {
        DispatchQueue.main.async { [self] in
            self.quality = quality
            
            if self.quality != .faceDetected {
                isBlinking = false
            }
        }
    }
}
