//
//  InteractionManager.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/5/22.
//

import CoreGraphics
import SwiftUI

public class InteractionManager: ObservableObject {
    public typealias onBlink = (numberOfBlinks: Int, boundingBox: CGRect)
    public typealias onLongBlink = (duration: Int, boundingBox: CGRect)
    
    // Listeners
    private var interactionListeners = [InteractionListener]()
    private var blinkListeners: [BlinkListener] {
        interactionListeners.compactMap { $0 as? BlinkListener }
    }
    private var longBlinkListeners: [LongBlinkListener] {
        interactionListeners.compactMap { $0 as? LongBlinkListener }
    }
    private var hoverListeners: [HoverListener] {
        interactionListeners.compactMap { $0 as? HoverListener }
    }
    private var quickActionListeners: [QuickActionListener] {
        interactionListeners.compactMap { $0 as? QuickActionListener }
    }
    
    // MARK: - Listeners
    public func addListener(_ listener: InteractionListener) {
        interactionListeners.append(listener)
    }
    
    public func removeListener(_ listener: InteractionListener) {
        interactionListeners.removeAll { $0 == listener }
    }
    
    public func updateListener(_ listener: InteractionListener) {
        removeListener(listener)
        addListener(listener)
    }
    
    // MARK: - Blink Methods
    public func onBlink(onBlink: onBlink) {
        let numberOfBlinks = onBlink.numberOfBlinks
        let boundingBox = onBlink.boundingBox
        
        if numberOfBlinks == UXDefaults.quickActionBlinks {
            handleQuickActions()
            return
        }
        
        // Filter listeners to those that match the number of blinks.
        let possibleListeners = blinkListeners.filter { $0.numberOfBlinks == numberOfBlinks }
        runListenersWithMatchingBoundingBox(
            boundingBox: boundingBox,
            possibleListeners: possibleListeners)
    }
    
    public func onLongBlink(onLongBlink: onLongBlink) {
        let duration = onLongBlink.duration
        let boundingBox = onLongBlink.boundingBox
        
        // Filter listeners to those that match the number of blinks.
        let possibleListeners = longBlinkListeners.filter { $0.duration == duration }
        runListenersWithMatchingBoundingBox(
            boundingBox: boundingBox,
            possibleListeners: possibleListeners)
    }
    
    private func runListenersWithMatchingBoundingBox(
        boundingBox: CGRect,
        possibleListeners: [InteractionListener]
    ) {
        // Run the action for each listener if the cursor is inside the listener's view.
        for listener in possibleListeners where listener.boundingBox.contains(boundingBox.origin) {
            listener.action()
        }
    }
    
    // MARK: - Hovering
    public func onCursorOffsetChanged(boundingBox: CGRect) {
        // Updates each listner if the cursor is hovering over it's view.
        for listener in hoverListeners {
            withAnimation {
                listener.isHovering = listener.boundingBox.contains(boundingBox.origin)
            }
        }
    }
    
    // MARK: - Quick Actions
    private func handleQuickActions() {
        // Sort by priority, greatest to least.
        let listeners = quickActionListeners.sorted { $0.priority > $1.priority }
        
        for listener in listeners {
            // Run the first listener's (with passing conditions) action.
            if listener.conditionsMet() {
                listener.action()
                break
            }
        }
    }
}
