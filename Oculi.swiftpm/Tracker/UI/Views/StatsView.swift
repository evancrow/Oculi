//
//  StatsView.swift
//  
//
//  Created by Evan Crow on 4/8/22.
//

import SwiftUI

struct StatsView: View {
    @EnvironmentObject var model: EyeTrackerModel
    @State var isVisible = false
    
    var infoButtonConfig: BlinkButtonStyleConfig {
        BlinkButtonStyleConfig(
            textColor: .blue,
            backgroundColor: .blue.opacity(UXDefaults.backgroundOpacity),
            cornerRadius: isVisible ? 0: UXDefaults.backgroundCornerRadius,
            showInteractionDetails: true)
    }
    
    var qualityColor: Color {
        switch model.quality {
        case .faceDetected:
            return .blue
        case .faceDetectedNotUsable:
            return .red
        case.noFaceDetected:
            return Color(UIColor.label)
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            BlinkButton(name: "toggle-info") {
                withAnimation(.easeOut) {
                    isVisible.toggle()
                }
            } label: {
                VStack {
                    Image(systemName: "info")
                }
            }.environment(\.buttonConfigStyle, infoButtonConfig)
            
            VStack(alignment: .leading, spacing: 4) {
                if isVisible {
                    Text("Quality: ")
                        .statHeaderViewStyle()
                    + Text("\(model.quality.rawValue)")
                        .foregroundColor(qualityColor)
                    
                    Text("Tracking: ")
                        .statHeaderViewStyle()
                    + Text("\(model.isTracking ? "true\(model.paused ? ", (paused)" : "")" : "false")")
                    
                    Text("Blinking: ")
                        .statHeaderViewStyle()
                    + Text("\(model.isBlinking ? "true" : "false")")
                    
                    BlinkButton(name: "recalibrate") {
                        model.resetBlinkingCalibration()
                    } label: {
                        Text("Recalibrate eyes")
                    }.environment(\.buttonConfigStyle, .basicRedAlt).padding(.top)
                }
            }
            .padding()
            .background(Color.blue.opacity(UXDefaults.backgroundOpacity))
            .opacity(isVisible ? 1 : 0)
            .transition(.slide)
        }
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
            .environmentObject(EyeTrackerModel())
            .environmentObject(InteractionManager())
            .environmentObject(GeometryProxyValue())
    }
}

fileprivate extension Text {
    func statHeaderViewStyle() -> Text {
        return self
            .foregroundColor(.blue)
            .fontWeight(.semibold)
    }
}
