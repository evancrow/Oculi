//
//  VisionModel.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/1/22.
//

import Vision
import SwiftUI

public enum QualityState: String {
    case faceDetected = "Face Detected"
    case faceDetectedNotUsable = "Face Detected (poor)"
    case noFaceDetected = "No Face Detected"
}

class VisionModel: ObservableObject {
    private let eyeTrackerDelegate: EyeTrackerDelegate!
    
    // MARK: - Tracking Requests
    public func createDetectionRequests(
        pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation,
        requestHandlerOptions: [VNImageOption: AnyObject]
    ) {
        let detectFaceRectanglesRequest = VNDetectFaceRectanglesRequest(completionHandler: detectedFaceRectangles)
        detectFaceRectanglesRequest.revision = VNDetectFaceRectanglesRequestRevision3

        let detectFaceLandmarksRequest = VNDetectFaceLandmarksRequest(completionHandler: detectedFaceLandmarksRequest)
        detectFaceLandmarksRequest.revision = VNDetectFaceRectanglesRequestRevision3
        
        let detectCaptureQualityRequest = VNDetectFaceCaptureQualityRequest(completionHandler: detectedFaceQualityRequest)
        detectCaptureQualityRequest.revision = VNDetectFaceCaptureQualityRequestRevision2
        
        performDetectRequests(requests: [detectFaceRectanglesRequest,
                                         detectFaceLandmarksRequest,
                                         detectCaptureQualityRequest],
                              pixelBuffer: pixelBuffer,
                              orientation: orientation,
                              requestHandlerOptions: requestHandlerOptions)
    }
    
    private func detectedFaceRectangles(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNFaceObservation],
            let result = results.first else {

            return
        }
        
        let faceGeometry = FaceGeometry(
            boundingBox: result.boundingBox,
            roll: Double(truncating: result.roll ?? 0),
            pitch: Double(truncating: result.pitch ?? 0),
            yaw: Double(truncating: result.yaw ?? 0)
        )
        
        DispatchQueue.main.async {
            self.eyeTrackerDelegate.faceGeometryDidChange(faceGeometry)
        }
    }
    
    private func detectedFaceLandmarksRequest(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNFaceObservation],
            let result = results.first,
            let landmarks = result.landmarks else {
            
            return
        }
        
        DispatchQueue.main.async {
            self.eyeTrackerDelegate.landmarksDidChange(landmarks)
        }
    }
    
    private func detectedFaceQualityRequest(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNFaceObservation],
            let result = results.first,
            let captureQuality = result.faceCaptureQuality else {
            
            eyeTrackerDelegate.faceCaptureQualityDidChange(.noFaceDetected)
            return
        }
        
        eyeTrackerDelegate.faceCaptureQualityDidChange(
            captureQuality > UXDefaults.minimumCaptureQuality ? .faceDetected : .faceDetectedNotUsable
        )
    }
    
    public func performDetectRequests(
        requests: [VNRequest]?, pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation, requestHandlerOptions: [VNImageOption: AnyObject]
    ) {
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                        orientation: orientation,
                                                        options: requestHandlerOptions)
        
        do {
            guard let requests = requests else {
                return
            }
            
            try imageRequestHandler.perform(requests)
        } catch let error as NSError {
            NSLog("Failed to perform request: %@", error)
        }
    }
    
    // MARK: - init
    init(eyeTrackerDelegate: EyeTrackerDelegate) {
        self.eyeTrackerDelegate = eyeTrackerDelegate
    }
}
