//
//  InteractingView.swift
//  
//
//  Created by Evan Crow on 4/8/22.
//

import SwiftUI

struct InteractingView: View {
    @EnvironmentObject var model: EyeTrackerModel
    @EnvironmentObject var interactionManager: InteractionManager
    
    @State var buttonsShouldBeRed = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Interacting!")
                    .welcomeSectionHeaderStyle()
                
                Text("There are two basic element interactions:")
            
                VStack(alignment: .leading, spacing: 48) {
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Text("Blinks")
                                .fontWeight(.semibold)
                            
                            Text("Hover a button and blink (number of times indicated on the icon), consciously and quickly.")
                        }
                        
                        BlinkButton(name: "example-blink") {
                            buttonsShouldBeRed.toggle()
                        } label: {
                            Text("Example Blink Button")
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Text("Long Blinks")
                                .fontWeight(.semibold)
                            
                            Text("Hover a button and long blink (duration in seconds indicated on the icon).")
                            + Text(" Long blinks can be identified by the filled in eye icon.")
                        }
                        
                        LongBlinkButton(duration: 2, name: "example-long-blink") {
                            buttonsShouldBeRed.toggle()
                        } label: {
                            Text("Example Long Blink Button")
                        }
                    }
                    
                    /* Disabling this for now 
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Text("Quick Actions")
                                .fontWeight(.semibold)
                            
                            Text("Blink three times anywhere on the screen. Context based and adapts to what you might want to do next.")
                            + Text(" Objects with a quick action have a mint border.")
                        }
                        
                        BlinkButton(name: "example-quick-action") {
                            buttonsShouldBeRed.toggle()
                        } label: {
                            Text("Example Quick Action Button")
                        }.onQuickAction(
                            name: UUID().uuidString,
                            interactionManager: interactionManager,
                            conditionsMet: { return true }
                        ) {
                            buttonsShouldBeRed.toggle()
                        }
                    }*/
                }
            }.environment(\.buttonConfigStyle, buttonsShouldBeRed ? .basicRedAlt : .basic)
            
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

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        InteractingView()
            .environmentObject(EyeTrackerModel())
            .environmentObject(InteractionManager())
            .environmentObject(GeometryProxyValue())
    }
}
