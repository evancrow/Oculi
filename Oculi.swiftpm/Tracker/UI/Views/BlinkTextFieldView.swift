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
    
    let placeholder: String
    @State var text: String
    @State var enableTextFieldQuickAction = false
    @FocusState var focusTextField: Bool
    
    // Microphone aniamtion
    /// Either 0 or 1, both will have a different effect.
    @State var microphoneAnimationState: Int = 0
    @State var animationTimer: Timer?
    
    var id: String {
        return placeholder
    }
    
    var speechRecognizerIsActive: Bool {
        focusTextField && speechRecognizerModel.isListening
    }
    
    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .focused($focusTextField)
                .padding()
                .background(
                    Color.blue
                        .opacity(UXDefaults.backgroundOpacity)
                        .cornerRadius(UXDefaults.backgroundCornerRadius)
                ).onBlink(name: placeholder, interactionManager: interactionManager) {
                    focusTextField = true
                }.onQuickAction(
                    name: id,
                    interactionManager: interactionManager,
                    priority: 1,
                    conditionsMet: { return enableTextFieldQuickAction }
                ) {
                    focusTextField = false
                }.onChange(of: focusTextField) { newValue in
                    if focusTextField {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            speechRecognizerModel.startListening(with: id)
                        }
                    } else {
                        speechRecognizerModel.stopListening(with: id)
                    }
                    
                    self.enableTextFieldQuickAction = self.focusTextField
                }.onChange(of: speechRecognizerModel.isListening) { _ in
                    if speechRecognizerIsActive {
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
                }.onChange(of: speechRecognizerModel.transcript) { transcript in
                    guard let transcriptForTextField = transcript[id] else {
                        return
                    }
                    
                    self.text = transcriptForTextField
                }
            
            if speechRecognizerIsActive {
                Image(systemName: "waveform.and.mic")
                    .foregroundColor(microphoneAnimationState == 0 ? Color(uiColor: .label) : .blue)
            }
        }
    }
}

struct BlinkTextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        BlinkTextFieldView(placeholder: "Placeholder", text: "")
            .environmentObject(GeometryProxyValue())
            .environmentObject(InteractionManager())
            .environmentObject(SpeechRecognizerModel())
    }
}
