//
//  ContentView.swift
//  EyeTracker
//
//  Created by Evan Crow on 2/28/22.
//

import SwiftUI

/// Example Root View
public struct ContentView: View {
    @EnvironmentObject var model: EyeTrackerModel
    @State var useSoundEffects = false
    
    public var body: some View {
        VStack(spacing: 24) {
            DemoView()
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("Quality: \(model.quality.rawValue)")
                Text("Tracking: \(model.isTracking ? "true\(model.paused ? ", (paused)" : "")" : "false")")
                Text("Blinking: \(model.isBlinking ? "true" : "false")")

                Text("Blink for \(UXDefaults.toggleTrackingBlinkDuration) seconds to toggle tracking")
            }
            
            VStack {
                BlinkToggle(
                    label: "Use Sound Effects",
                    toggleState: $useSoundEffects
                ).onChange(of: useSoundEffects) { newValue in
                    SoundEffectHelper.shared.shouldPlaySoundEffects = newValue
                }
                
                BlinkButton {
                    model.toggleTrackingState()
                } label: {
                    Text("Toggle Tracking State")
                }
            }
        }
    }
    
    public init() {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
