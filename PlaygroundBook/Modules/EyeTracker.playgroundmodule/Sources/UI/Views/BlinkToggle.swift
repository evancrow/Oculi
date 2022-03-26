//
//  BlinkToggle.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/6/22.
//

import SwiftUI

struct BlinkToggle: View {
    var label: String
    
    @Binding var toggleState: Bool
    @EnvironmentObject private var interactionManager: InteractionManager
    
    var body: some View {
        Toggle(isOn: $toggleState) {
            Text(label)
                .fontWeight(.semibold)
                .padding(.trailing)
        }.onBlink(interactionManager: interactionManager) {
            toggleState.toggle()
        }.fixedSize()
    }
}

struct BlinkToggle_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geom in
            HStack {
                Spacer()
                    
                BlinkToggle(label: "Test", toggleState: .constant(true))
                    
                Spacer()
            }
            .environmentObject(GeometryProxyValue())
            .environmentObject(InteractionManager())
        }
    }
}
