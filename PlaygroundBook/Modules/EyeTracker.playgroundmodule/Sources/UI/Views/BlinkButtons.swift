//
//  BlinkButton.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/5/22.
//

import SwiftUI

struct BlinkButton<Label: View>: View {
    private var numberOfBlinks: Int
    private var config: BlinkButtonStyleConfig
    private var action: () -> Void
    private var label: Label
    
    @State private var isHovering: Bool = false
    @Environment(\.isEnabled) private var isEnabled
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
        .onBlink(interactionManager: interactionManager, numberOfBlinks: numberOfBlinks, action: action)
        .onEyeHover(interactionManager: interactionManager) { isHovering in
            self.isHovering = isHovering
        }
    }
    
    init(
        numberOfBlinks: Int = UXDefaults.defaultBlinksForInteraction,
        config: BlinkButtonStyleConfig = .basic,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.numberOfBlinks = numberOfBlinks
        self.config = config
        self.action = action
        self.label = label()
    }
}

struct LongBlinkButton<Label: View>: View {
    private var duration: Int
    private var config: BlinkButtonStyleConfig
    private var action: () -> Void
    private var label: Label
    
    @State private var isHovering: Bool = false
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
        .onLongBlink(interactionManager: interactionManager, duration: duration, action: action)
        .onEyeHover(interactionManager: interactionManager) { isHovering in
            self.isHovering = isHovering
        }
    }
    
    init(
        duration: Int,
        config: BlinkButtonStyleConfig = .basic,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.duration = duration
        self.config = config
        self.action = action
        self.label = label()
    }
}

struct BlinkButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            BlinkButton {} label: { Text("Blink Button") }
        }
        .environmentObject(InteractionManager())
        .environmentObject(GeometryProxyValue())
    }
}
