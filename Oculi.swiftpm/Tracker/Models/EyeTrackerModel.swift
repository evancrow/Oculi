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
    
    // Calibration
    @Published public private(set) var showBlinkingCalibrationView = false
    @Published public private(set) var blinkingHasBeenCalibrated = false
    @Published public private(set) var isCalibratingEyes = false
    
    // Current blink info. 
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
    
    private var leftEyePoints = [CGPoint]()
    private var rightEyePoints = [CGPoint]()
    
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
        if !blinkingHasBeenCalibrated {
            withAnimation {
                showBlinkingCalibrationView = true
            }
        } else {
            resetOffset()
            isTracking = true
        }
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    public func endTracking() {
        isTracking = false
        interactionManager.onCursorOffsetChanged(boundingBox: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    // MARK: - Blinking
    private func getEyeHeight(points: [CGPoint], useAbs: Bool = false) -> CGFloat {
        guard quality == .faceDetected, points.count == 6 else {
            return -1
        }
        
        // Point layout (eye):
        // /-2-3-\
        // 1  •  4
        // \-6-5-/
        
        let p2 = points[1]
        let p3 = points[2]
        let p5 = points[4]
        let p6 = points[5]
        
        let leftHeight = useAbs ? abs(p2.y - p6.y) : (p2.y - p6.y)
        let rightHeight =  useAbs ? abs(p3.y - p5.y) : (p3.y - p5.y)
        
        // return the average of the two
        return (leftHeight + rightHeight) / 2
    }
    
    private func checkIfEyeIsBlinking(points: [CGPoint]) -> Bool {
        let eyeHeight = getEyeHeight(points: points, useAbs: true)
        let threshold = UXDefaults.isBlinkingMargin
        
        guard eyeHeight > 0 else {
            return false
        }

        return eyeHeight < threshold
    }
    
    private func blinkStateChanged() {
        if isBlinking {
            SoundEffectHelper.shared.playAudio(for: .onBlink)
            
            // User blinked again very quickly,
            // should count this as another blink in the group.
            if let blinkGroupTimer = blinkGroupTimer, blinkGroupTimer.isValid {
                currentNumberOfBlinks += 1
                blinkGroupTimer.invalidate()
            }
            
            blinkDurationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                SoundEffectHelper.shared.playAudio(for: .onBlink)
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
            // Disable for now, as it could be confusing to the user.
            // toggleTrackingState()
        }
        
        interactionManager.onLongBlink(onLongBlink: (seconds, getCursorBoundingBox()))
    }
    
    // Called when the user stops blinking
    private func blinksEnded() {
        let numberOfBlinks = currentNumberOfBlinks + 1
        interactionManager.onBlink(onBlink: (numberOfBlinks, getCursorBoundingBox()), isTracking: isTracking)
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
    
    // Calibration
    public func startBlinkingCalibration() {
        // How many measurements to take
        let count = 20
        
        isCalibratingEyes = true
        
        // Add a small delay to make sure the user closes their eyes
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
            var eyeHeights = [(CGFloat, CGFloat)]()
            
            Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [self] timer in
                eyeHeights.append((getEyeHeight(points: leftEyePoints), getEyeHeight(points: rightEyePoints)))
                
                if eyeHeights.count == count {
                    timer.invalidate()
                    
                    // Get average of each height
                    let leftHeights = eyeHeights.map { $0.0 }
                    let leftAverage = leftHeights.reduce(0, +) / CGFloat(count)
                    
                    let rightHeights = eyeHeights.map { $0.1 }
                    let rightAverage = rightHeights.reduce(0, +) / CGFloat(count)

                    let bothEyeAverage = ((leftAverage + rightAverage) / 2)
                    
                    UXDefaults.isBlinkingMargin = bothEyeAverage + (bothEyeAverage * 0.2)
                    
                    blinkingHasBeenCalibrated = true
                    isCalibratingEyes = false
                    
                    SoundEffectHelper.shared.playAudio(for: .onComplete)
                }
            }
        }
    }
    
    public func displayBlinkingCalibrationViewIfNeeded() {
        guard !blinkingHasBeenCalibrated else {
            return
        }
        
        showBlinkingCalibrationView = true
    }
    
    public func hideBlinkingCalibrationViewIfCompleted() {
        guard blinkingHasBeenCalibrated else {
            return
        }
        
        showBlinkingCalibrationView = false
    }
    
    public func resetBlinkingCalibration() {
        blinkingHasBeenCalibrated = false
        showBlinkingCalibrationView = true
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
            
            self.leftEyePoints = leftEyePoints
            self.rightEyePoints = rightEyePoints
            
            let leftEyeBlinking = checkIfEyeIsBlinking(points: leftEyePoints)
            let rightEyeBlinking = checkIfEyeIsBlinking(points: rightEyePoints)
            let blinking = leftEyeBlinking && rightEyeBlinking
            
            // Don't update state if it's not necessary.
            if blinking != isBlinking && blinkingHasBeenCalibrated {
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
