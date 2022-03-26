//
//  PermissionModel.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/6/22.
//

import AVKit
import Combine
import Speech

enum PermissionState {
    case unknown
    case authorized
    case denied
    case unable
}

enum Permission: String, CaseIterable  {
    case camera = "camera"
    case microphone = "microphone"
    case speechRecognition = "speech recognition"
}

class PermissionModel: ObservableObject {
    static let shared = PermissionModel()
    
    @Published var permissionStates: [Permission: PermissionState]
    let requiredPermissions: [Permission] = [.camera, .microphone]
    
    var nextRequiredPermission: (Permission, PermissionState)? {
        for permissionKey in permissionStates.keys {
            if let permissionState = permissionStates[permissionKey],
               requiredPermissions.contains(permissionKey), permissionState != .authorized {
                return (permissionKey, permissionState)
            }
        }
        
        return nil
    }
    
    /// Gets the permission state from the system.
    public func getPermissionState(permission: Permission, completion: @escaping (PermissionState) -> Void) {
        requestPermissionIfNeeded(permission: permission) { state in
            DispatchQueue.main.async {
                self.permissionStates[permission] = state
                completion(state)
            }
        }
    }
    
    /// Checks if the user has given permsission to use the input, and requests it if needed.
    private func requestPermissionIfNeeded(permission: Permission, completion: @escaping (PermissionState) -> Void) {
        switch permission {
        
        case .camera:
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                completion(.authorized)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    completion(granted ? .authorized : .denied)
                }
            case .denied:
                completion(.denied)
            case .restricted:
                completion(.unable)
            @unknown default:
                completion(.unable)
            }
        case .microphone:
            switch AVAudioSession.sharedInstance().recordPermission {
            case .granted:
                completion(.authorized)
            case .undetermined:
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    completion(granted ? .authorized : .denied)
                }
            case .denied:
                completion(.denied)
            @unknown default:
                completion(.unable)
            }
        case .speechRecognition:
            switch SFSpeechRecognizer.authorizationStatus() {
            case .authorized:
                completion(.authorized)
            case .denied:
                completion(.denied)
            case .restricted:
                completion(.unable)
            case .notDetermined:
                SFSpeechRecognizer.requestAuthorization { (authStatus) in
                    switch authStatus {
                    case .authorized:
                        completion(.authorized)
                    case .denied:
                        completion(.denied)
                    case .restricted, .notDetermined:
                        completion(.unable)
                    @unknown default:
                        completion(.unable)
                    }
                }
            @unknown default:
                completion(.unable)
            }
        }
    }
    
    // MARK: - init
    init() {
        var permissionStates: [Permission: PermissionState] = [:]
        for permission in Permission.allCases {
            permissionStates[permission] = .unknown
        }
        
        self.permissionStates = permissionStates
    }
}
