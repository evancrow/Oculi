//
//  QuickActionDemos.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/7/22.
//

import SwiftUI

struct QuickActionDemos: View {
    @State var buttonsShouldBeRed = false
    @EnvironmentObject private var interactionManager: InteractionManager
    @EnvironmentObject private var speechRecognizerModel: SpeechRecognizerModel
    
    var body: some View {
        BlinkButton(
            config: buttonsShouldBeRed ? .basicRedAlt : .basic
        ) {
            print("Quick Action Button Triggered")
            buttonsShouldBeRed.toggle()
        } label: {
            Text("Quick Action Button")
        }.onQuickAction(
            interactionManager: interactionManager,
            conditionsMet: { return true }
        ) {
            buttonsShouldBeRed.toggle()
        }
        
        BlinkTextFieldView()
    }
}

struct QuickActionDemos_Previews: PreviewProvider {
    static var previews: some View {
        QuickActionDemos()
            .environmentObject(GeometryProxyValue())
            .environmentObject(InteractionManager())
            .environmentObject(SpeechRecognizerModel())
    }
}
