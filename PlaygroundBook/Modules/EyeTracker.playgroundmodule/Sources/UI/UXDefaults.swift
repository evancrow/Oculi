//
//  UXDefaults.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/5/22.
//

import CoreGraphics

public struct UXDefaults {
    /// The minimum quality allowed by `VisionModel` to recognize the face as usable.
    /// The lower the number, the less strict and less acurate the data may be.
    internal static let minimumCaptureQuality: Float = 0.2
    
    // MARK: - Blinking
    /// The error margin which eye height has to be under for `EyeTrackerModel` to recognize as blinking.
    /// The lower the number, the stricter the model is. 
    internal static let isBlinkingMargin = 0.025
   
    // Quick blinks
    /// Default number of blinks required for a button to register interaction.
    internal static let defaultBlinksForInteraction = 2
    /// Number of blinks required to trigger a quick action.
    internal static let quickActionBlinks = 3
    /// Maximum duration of time (seconds) allowed between a blink for it to be
    /// counted as a group.
    internal static let maximumBlinkSeperationTime: Double = 0.75
    
    // Long blinks
    /// Blink length required to start a drag interaction on an object.
    internal static let dragDropBlinkDuration = 2
    /// Blink length required to toggle tracking state.
    internal static let toggleTrackingBlinkDuration = 4
    
    // MARK: - Cursor
    // Cursor
    internal static let cursorHeight: CGFloat = 25
    /// How much to increase the speed of the cursor by.
    /// `Width` is how much to increase `x` by and `height` for `y`.
    public static var movmentMultiplier: CGSize = CGSize(width: 12, height: 15)
    
    // MARK: - UI
    internal static let backgroundOpacity: CGFloat = 0.2
    /// How much the `backgroundOpacity` should change if the cursor is hovering over a view.
    internal static let hoverOpacityMultiplier: CGFloat = 2
    /// How much the `backgroundOpacity` should change if a view is disabled.
    internal static let disabledOpacityMultiplier: CGFloat = 0.5
    internal static let backgroundCornerRadius: CGFloat = 12
}
