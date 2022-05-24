//
//  BlinkButton.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/5/22.
//

import SwiftUI

struct BlinkButton<Label: View>: View {
    private var name: String
    private var numberOfBlinks: Int
    private var action: () -> Void
    private var label: Label
    
    @State private var isHovering: Bool = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.buttonConfigStyle) private var config
    @EnvironmentObject private var interactionManager: InteractionManager
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                if config.showInteractionDetails {
                    EyeIcon(type: .blink, count: numberOfBlinks)
                }
                
                label
            }
        }
        .modifier(BlinkButtonStyle(config: config, hovering: isHovering, isEnabled: isEnabled))
        .onBlink(name: name, interactionManager: interactionManager, numberOfBlinks: numberOfBlinks, action: action)
        .onEyeHover(name: name, interactionManager: interactionManager) { isHovering in
            self.isHovering = isHovering
        }
    }
    
    init(
        numberOfBlinks: Int = UXDefaults.defaultBlinksForInteraction,
        name: String,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.numberOfBlinks = numberOfBlinks
        self.name = name
        self.action = action
        self.label = label()
    }
}

struct LongBlinkButton<Label: View>: View {
    private var name: String
    private var duration: Int
    private var action: () -> Void
    private var label: Label
    
    @State private var isHovering: Bool = false
    @Environment(\.buttonConfigStyle) private var config
    @EnvironmentObject private var interactionManager: InteractionManager
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                if config.showInteractionDetails {
                    EyeIcon(type: .longBlink, count: duration)
                }
                
                label
            }
        }
        .modifier(BlinkButtonStyle(config: config, hovering: isHovering))
        .onLongBlink(name: name, interactionManager: interactionManager, duration: duration, action: action)
        .onEyeHover(name: name, interactionManager: interactionManager) { isHovering in
            self.isHovering = isHovering
        }
    }
    
    init(
        duration: Int,
        name: String,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.duration = duration
        self.name = name
        self.action = action
        self.label = label()
    }
}

struct BlinkButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            BlinkButton(name: "example-blink") {} label: { Text("Blink Button") }
        }
        .environmentObject(InteractionManager())
        .environmentObject(GeometryProxyValue())
    }
}
