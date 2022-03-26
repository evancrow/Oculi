//
//  InteractionModifiers.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/5/22.
//

import SwiftUI

fileprivate struct ViewBoundsListenerModifier: ViewModifier {
    let onViewBoundsChanged: (CGRect) -> Void
    
    @State private var bounds: Anchor<CGRect>?
    @EnvironmentObject private var geometryProxyValue: GeometryProxyValue
   
    func body(content: Content) -> some View {
        content
            .anchorPreference(
                key: BoundsPreferenceKey.self,
                value: .bounds
            ) { $0 }
            .onPreferenceChange(BoundsPreferenceKey.self) { bounds in
                bounds.map {
                    self.bounds = $0
                }
            }.useEffect(deps: geometryProxyValue.geomUpdated) { geom in
                updateBounds()
            }
    }
    
    func updateBounds() {
        guard let geom = geometryProxyValue.geom,
            let bounds = bounds else {
            return
        }
        
        onViewBoundsChanged(geom[bounds])
    }
}

extension View {
    /// Listens for a specific number of blinks on a view.
    /// - Parameters:
    ///   - numberOfBlinks: Number of blinks to listen for, CANNOT be the same as the amount for Quick Actions.
    func onBlink(
        interactionManager: InteractionManager,
        numberOfBlinks: Int = UXDefaults.defaultBlinksForInteraction,
        action: @escaping () -> Void
    ) -> some View {
        if numberOfBlinks == UXDefaults.quickActionBlinks {
            fatalError("\(numberOfBlinks) blinks is reserved for Quick Actions. Change the number of blinks or use onQuickAction.")
        }
        
        var listener: InteractionListener?
        
        return self.modifier(
            ViewBoundsListenerModifier { bounds in
                listener = BlinkListener(
                    id: "blink-listener",
                    numberOfBlinks: numberOfBlinks,
                    boundingBox: bounds,
                    action: {
                        SoundEffectHelper.shared.playAudio(for: .onAction)
                        action()
                    })
                
                interactionManager.updateListener(listener!)
            }
        ).onDisappear {
            if let listener = listener {
                interactionManager.removeListener(listener)
            }
        }
    }
    
    func onLongBlink(
        interactionManager: InteractionManager,
        duration: Int,
        action: @escaping () -> Void
    ) -> some View {
        var listener: InteractionListener?
        
        return self.modifier(
            ViewBoundsListenerModifier { bounds in
                listener = LongBlinkListener(
                    id: "long-blink-listener", duration: duration,
                    boundingBox: bounds, action: action)
                
                interactionManager.updateListener(listener!)
            }
        ).onDisappear {
            if let listener = listener {
                interactionManager.removeListener(listener)
            }
        }
    }
    
    /// Adds a listener for when the eye cursor is over the view.
    func onEyeHover(
        interactionManager: InteractionManager,
        onHoverStateChanged: @escaping (Bool) -> Void
    ) -> some View {
        var listener: InteractionListener?
        
        return self.modifier(
            ViewBoundsListenerModifier { bounds in
                listener = HoverListener(
                    id: "hover-listener",
                    boundingBox: bounds,
                    onHoverChanged: { isHovering in
                        if isHovering {
                            SoundEffectHelper.shared.playAudio(for: .onHover)
                        }
                        
                        onHoverStateChanged(isHovering)
                    })
                
                interactionManager.updateListener(listener!)
            }
        ).onDisappear {
            if let listener = listener {
                interactionManager.removeListener(listener)
            }
        }
    }
    
    /// - Parameters:
    ///   - priority: Value from 0-1 which ranks how important this Quick Action is compared to others
    ///               (if multiple are present). Default is 0.5.
    func onQuickAction(
        name: String = "",
        interactionManager: InteractionManager,
        priority: Double = 0.5,
        cornerRadius: CGFloat = UXDefaults.backgroundCornerRadius,
        conditionsMet: @escaping () -> Bool,
        action: @escaping () -> Void
    ) -> some View {
        var listener: InteractionListener?
        
        var viewWithListeners: some View {
            self
                .onAppear {
                    listener = QuickActionListener(
                        id: "quick-action-listener-\(name)",
                        priority: priority,
                        conditionsMet: conditionsMet,
                        action: {
                            SoundEffectHelper.shared.playAudio(for: .onAction)
                            action()
                        }
                    )
                    
                    interactionManager.updateListener(listener!)
                }
                .onDisappear {
                    if let listener = listener {
                        interactionManager.removeListener(listener)
                    }
                }
        }
        
        @ViewBuilder
        var viewWithQuickActionIdentifiers: some View {
            viewWithListeners
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.mint.opacity(priority), lineWidth:  conditionsMet() ? 4 : 0)
                )
        }
        
        return viewWithQuickActionIdentifiers
    }
}

struct InteractionModifier_Previews: PreviewProvider {
    static var previews: some View {
        BlinkButton {} label: {
            Text("Quick Action Button")
        }.onQuickAction(
            interactionManager: InteractionManager(),
            conditionsMet: { return true }
        ) {}
        .environmentObject(GeometryProxyValue())
        .environmentObject(InteractionManager())
    }
}
