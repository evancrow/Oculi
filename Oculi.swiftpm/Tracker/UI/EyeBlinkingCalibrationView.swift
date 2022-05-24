//
//  EyeBlinkingCalibrationView.swift
//  
//
//  Created by Evan Crow on 4/10/22.
//

import SwiftUI

struct EyeBlinkingCalibrationView: View {
    @EnvironmentObject var model: EyeTrackerModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(model.blinkingHasBeenCalibrated ? "Calibration Succesful!" : "Calibration")
                    .font(.largeTitle)
                    .bold()
                    
                if !model.blinkingHasBeenCalibrated {
                    Text("Oculi quickly needs to calibrate to your eye's blinking before you can continue. Having trouble? Make sure you're in a well lit area for best results.")
                        .foregroundColor(.secondary)
                        .fontWeight(.semibold)
                        .padding(.bottom)
                }
            }
                
            if model.blinkingHasBeenCalibrated {
                Text("Continue holding your device the same way. If you ever need to recalibrate, tap the info button in the top right corner.")
                
                BlinkButton(name: "finish-calibration") {
                    model.hideBlinkingCalibrationViewIfCompleted()
                } label: {
                    Text("Continue")
                }
            } else {
                Text("Hold your device still at arms length (two feet), and at eye level.")
                Text("Tap the button below and close your eyes for four seconds (You'll hear a ding when complete).")
                
                if !model.isCalibratingEyes {
                    BlinkButton(name: "start-calibration") {
                        model.startBlinkingCalibration()
                    } label: {
                        Text("Start Blinking")
                    }
                }
            }
        }
    }
}

struct EyeBlinkingCalibrationView_Previews: PreviewProvider {
    static var previews: some View {
        EyeBlinkingCalibrationView()
            .environmentObject(EyeTrackerModel())
            .environmentObject(InteractionManager())
            .environmentObject(GeometryProxyValue())
    }
}
