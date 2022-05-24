//
//  InteractionListener.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/5/22.
//

import Foundation
import CoreGraphics

public class InteractionListener: Equatable {
    private let id: String
    
    /// The bounding box for the view the listener is attached too.
    public let boundingBox: CGRect
    
    /// The code that should be run if the conditions are met for the listener.
    public let action: () -> Void
    
    init(id: String, boundingBox: CGRect, action: @escaping () -> Void) {
        self.id = id
        self.boundingBox = boundingBox
        self.action = action
    }
    
    public static func == (lhs: InteractionListener, rhs: InteractionListener) -> Bool {
        lhs.id == rhs.id
    }
}

class BlinkListener: InteractionListener {
    public let numberOfBlinks: Int
    
    init(
        id: String = "",
        numberOfBlinks: Int,
        boundingBox: CGRect,
        action: @escaping () -> Void
    ) {
        self.numberOfBlinks = numberOfBlinks
        super.init(id: id, boundingBox: boundingBox, action: action)
    }
}

class LongBlinkListener: InteractionListener {
    public let duration: Int
    
    init(
        id: String = "",
        duration: Int,
        boundingBox: CGRect,
        action: @escaping () -> Void
    ) {
        self.duration = duration
        super.init(id: id, boundingBox: boundingBox, action: action)
    }
}

class HoverListener: InteractionListener {
    private let onHoverChanged: (Bool) -> Void
    public var isHovering = false {
        didSet {
            if oldValue != isHovering {
                onHoverChanged(isHovering)
            }
        }
    }
    
    init(
        id: String = "",
        boundingBox: CGRect,
        onHoverChanged: @escaping (Bool) -> Void
    ) {
        self.onHoverChanged = onHoverChanged
        super.init(id: id, boundingBox: boundingBox, action: {})
    }
}

class QuickActionListener: InteractionListener {
    public let priority: Double
    public let conditionsMet: () -> Bool
    /// If `true` the Quick Action can still be run if tracking is off.
    public var overrideIsTracking: Bool
    
    init(
        id: String = "",
        priority: Double,
        overrideTracking: Bool = false,
        conditionsMet: @escaping () -> Bool,
        action: @escaping () -> Void
    ) {
        self.priority = priority
        self.overrideIsTracking = overrideTracking
        self.conditionsMet = conditionsMet
        
        super.init(id: id, boundingBox: CGRect(), action: action)
    }
}
