//
//  BlinkTextFieldView.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/13/22.
//

import SwiftUI

struct BlinkTextFieldView: View {
    @EnvironmentObject private var interactionManager: InteractionManager
    @EnvironmentObject private var speechRecognizerModel: SpeechRecognizerModel
    
    @State var text = ""
    @State var enableTextFieldQuickAction = false
    @FocusState var focusTextField: Bool
    
    // Microphone aniamtion
    /// Either 0 or 1, both will have a different effect.
    @State var microphoneAnimationState: Int = 0
    @State var animationTimer: Timer?
    
    var body: some View {
        HStack {
            TextField("Quick Action TextField", text: $speechRecognizerModel.transcript)
                .focused($focusTextField)
                .padding()
                .background(
                    Color.blue
                        .opacity(UXDefaults.backgroundOpacity)
                        .cornerRadius(UXDefaults.backgroundCornerRadius)
                ).onBlink(interactionManager: interactionManager){
                    focusTextField = true
                }.onQuickAction(
                    name: "keyboardDismisser",
                    interactionManager: interactionManager,
                    priority: 1,
                    conditionsMet: { return enableTextFieldQuickAction }
                ) {
                    focusTextField = false
                }.onChange(of: focusTextField) { newValue in
                    if focusTextField {
                        speechRecognizerModel.startListening()
                    } else {
                        speechRecognizerModel.stopListening()
                    }
                    
                    self.enableTextFieldQuickAction = self.focusTextField
                }.onChange(of: speechRecognizerModel.isListening) { isListening in
                    if isListening {
                        animationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                            withAnimation {
                                microphoneAnimationState = (microphoneAnimationState == 0 ? 1 : 0)
                            }
                        }
                    } else {
                        animationTimer?.invalidate()
                        animationTimer = nil
                        microphoneAnimationState = 0
                    }
                }
            
            if speechRecognizerModel.isListening {
                Image(systemName: "waveform.and.mic")
                    .foregroundColor(microphoneAnimationState == 0 ? .black : .blue)
            }
        }
    }
}

struct BlinkTextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        BlinkTextFieldView()
            .environmentObject(GeometryProxyValue())
            .environmentObject(InteractionManager())
            .environmentObject(SpeechRecognizerModel())
    }
}
