//
//  BlinkButtonStyle.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/5/22.
//

import SwiftUI

struct BlinkButtonStyleConfig {
    let textColor: Color
    let backgroundColor: Color
    let cornerRadius: CGFloat
    
    static let basic = BlinkButtonStyleConfig(
        textColor: .blue,
        backgroundColor: .blue.opacity(UXDefaults.backgroundOpacity),
        cornerRadius: UXDefaults.backgroundCornerRadius)
    
    /// A red alternative version to `basic`
    static let basicRedAlt = BlinkButtonStyleConfig(
        textColor: .red,
        backgroundColor: .red.opacity(UXDefaults.backgroundOpacity),
        cornerRadius: UXDefaults.backgroundCornerRadius)
}

struct BlinkButtonStyle: ViewModifier {
    var config: BlinkButtonStyleConfig = .basic
    var hovering = false
    var isEnabled = true
    
    var opacityMultiplier: CGFloat {
        isEnabled ? (hovering ? UXDefaults.hoverOpacityMultiplier : 1) : UXDefaults.disabledOpacityMultiplier
    }
    
    func body(content: Content) -> some View {
        content
            .fixedSize()
            .padding()
            .foregroundColor(config.textColor)
            .background(
                config.backgroundColor.opacity(opacityMultiplier).cornerRadius(config.cornerRadius)
            )
    }
}


