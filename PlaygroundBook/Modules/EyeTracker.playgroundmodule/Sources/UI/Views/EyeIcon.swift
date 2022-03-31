//
//  EyeIcon.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/26/22.
//

import SwiftUI

public enum InteractionType {
    case blink
    case longBlink
}

/// Used for indicating to the user how to interacte with an element (i.e. Blinking/Long Blinking).
public struct EyeIcon: View {
    let type: InteractionType
    let count: Int
    
    var background: some View {
        Circle()
            .foregroundColor(Color(UIColor.systemBackground).opacity(0.9))
    }
    
    @ViewBuilder
    var icon: some View {
        if type == .blink {
            Image(systemName: "eye")
        } else {
            Image(systemName: "eye.fill")
        }
    }
    
    @ViewBuilder
    var countLabel: some View {
        Text(String(count))
            .font(.system(size: 10, weight: .semibold))
            .padding(4)
            .background(background)
    }
    
    public var body: some View {
        VStack(alignment: .trailing) {
            icon
            
            countLabel
                .padding(.top, -14)
                .padding(.trailing, -4)
        }.padding(.top, 8).padding(.horizontal, 4).background(background)
    }
}

struct EyeIcon_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            EyeIcon(type: .blink, count: 2)
            EyeIcon(type: .longBlink, count: 2)
        }.padding().background(Color.orange)
    }
}
