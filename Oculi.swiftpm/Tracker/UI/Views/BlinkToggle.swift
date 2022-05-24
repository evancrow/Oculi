//
//  BlinkToggle.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/6/22.
//

import SwiftUI

struct BlinkToggle: View {
    var label: String
    var description: String?
    
    @Binding var toggleState: Bool
    @EnvironmentObject private var interactionManager: InteractionManager
    
    var body: some View {
        BlinkButton(name: label) {
            toggleState.toggle()
        } label: {
            Toggle(isOn: $toggleState) {
                VStack(alignment: .leading) {
                    Text(label)
                        .fontWeight(.semibold)
                    
                    if let description = description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } .padding(.trailing)
            }.onBlink(name: label, interactionManager: interactionManager) {
                toggleState.toggle()
            }.fixedSize()
        }
    }
}

struct BlinkToggle_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) {
            Spacer()
                
            BlinkToggle(label: "Test", toggleState: .constant(true))
            BlinkToggle(label: "Test", description: "This is a description about what the toggle does.", toggleState: .constant(true))
                
            Spacer()
        }
        .environmentObject(GeometryProxyValue())
        .environmentObject(InteractionManager())
    }
}
