//
//  InteractionViewWrapper.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/21/22.
//

import SwiftUI

public struct InteractionViewWrapper<Content: View>: View {
    @ObservedObject var model = EyeTrackerModel()
    @ObservedObject var speechRecognizerModel = SpeechRecognizerModel()
    @ObservedObject var permissionModel = PermissionModel.shared
    @StateObject var geometryProxyValue = GeometryProxyValue()
    @State var keyboardVisible = false
    
    private let interactionManager = InteractionManager()
    private let content: Content
    
    @ViewBuilder
    var permissionErrorView: some View {
        if let nextRequiredPermission = permissionModel.nextRequiredPermission {
            switch nextRequiredPermission.1 {
            case .denied, .unknown:
                ErrorView(error: "Please give \(nextRequiredPermission.0.rawValue) permission in settings",
                          buttonText: "Check Again", buttonAction: model.resetAVModel)
            case .unable:
                ErrorView(
                    error: "Your device is not able to support requirment: \(nextRequiredPermission.0.rawValue)")
            default:
                EmptyView()
            }
        } else {
            EmptyView()
        }
    }
    
    public var body: some View {
        ZStack {
            if permissionModel.nextRequiredPermission == nil {
                GeometryReader { geom in
                    HStack {
                        Spacer()
                        content
                        Spacer()
                    }
                    .environmentObject(geometryProxyValue)
                    .environmentObject(interactionManager)
                    .environmentObject(speechRecognizerModel)
                    .padding(.bottom)
                    .useEffect(deps: geom.size) { _ in
                        model.updateViewValues(geom.size)
                        geometryProxyValue.geom = geom
                    }.useEffect(deps: geom.safeAreaInsets.bottom) { bottomSafeArea in
                        keyboardVisible = bottomSafeArea > 100
                    }.onChange(of: keyboardVisible) { _ in
                        model.keyboardVisible = keyboardVisible
                    }
                }
                
                if !keyboardVisible {
                    Cursor(offset: model.offset)
                }
            } else if permissionModel.nextRequiredPermission?.1 != .unknown {
                permissionErrorView
            }
        }.onAppear {
            model.config(interactionManager: interactionManager)
        }
    }
    
    public init(content: () -> Content) {
        self.content = content()
    }
}
