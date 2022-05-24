//
//  MovingAroundView.swift
//  
//
//  Created by Evan Crow on 4/8/22.
//

import SwiftUI

struct MovingAroundView: View {
    @EnvironmentObject var model: EyeTrackerModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Moving Around!")
                .welcomeSectionHeaderStyle()
            
            Text("Getting around with Oculi is a breeze.")
            
            Text("Keep your device still, and level with your head. Use your head like a mouse (up/down, left/right) to move the on screen cursor. Then navigate to an object to interact with it.")
            
            Spacer()
            
            if !model.isTracking {
                HStack {
                    Spacer()
                    
                    BlinkButton(name: "try-it-out") {
                        model.startTracking()
                    } label: {
                        Text("Try it out!")
                    }
                    
                    Spacer()
                }.padding(.top)
            }
        }
    }
}

struct MovingAroundView_Previews: PreviewProvider {
    static var previews: some View {
        MovingAroundView()
            .environmentObject(EyeTrackerModel())
            .environmentObject(InteractionManager())
            .environmentObject(GeometryProxyValue())
    }
}
