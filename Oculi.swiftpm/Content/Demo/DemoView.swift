//
//  DemoView.swift
//  
//
//  Created by Evan Crow on 4/7/22.
//

import SwiftUI

struct DemoView: View {
    @EnvironmentObject var model: EyeTrackerModel
    @EnvironmentObject var interactionManager: InteractionManager
    @EnvironmentObject var speechRecognizerModel: SpeechRecognizerModel
    
    @State var buttonsShouldBeRed = false
    @State var showMockPopover = false
    @State var useDictation = true
    @State var textFieldText = "Placeholder text"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Accessibility Playground")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Use this space to expermiment with system elements using Oculi, and see all the possible, real world use cases!")
                        .foregroundColor(.secondary)
                        .fontWeight(.semibold)
                        .padding(.bottom)
                    
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Preferences")
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    HStack {
                        LongBlinkButton(duration: 2, name: "toggle-button-color") {
                            buttonsShouldBeRed.toggle()
                        } label: {
                            Text("Change Button Color")
                        }
                        
                        BlinkToggle(
                            label: "Use Dictation",
                            description: "When enabled, all text fields will automatically use dictation when you focus them.",
                            toggleState: $speechRecognizerModel.dictationEnabled
                        )
                    }
                    
                    Text("Cursor Speed")
                        .font(.title3)
                    
                    HStack {
                        BlinkButton(name: "decrease-speed") {
                            UXDefaults.movmentMultiplier.width -= 1
                            UXDefaults.movmentMultiplier.height -= 1
                        } label: {
                            Text("Decrease Cursor Speed")
                        }.disabled(UXDefaults.movmentMultiplier.width <= 1)
                        
                        BlinkButton(name: "increase-speed") {
                            UXDefaults.movmentMultiplier.width += 1
                            UXDefaults.movmentMultiplier.height += 1
                        } label: {
                            Text("Increase Cursor Speed")
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick Actions")
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    Text("Quick Actions change based on what you likely want to do next. Try triggering the first quick action (3 blinks anywhere), and see the object with an active Quick Action change. Objects with quick actions have a mint border.")
                        .foregroundColor(.secondary)
                        .fontWeight(.semibold)
                    
                    BlinkButton(name: "show-popover") {
                        showMockPopover = true
                    } label: {
                        Text("Show Popover")
                    }.onQuickAction(name: "show-popover", interactionManager: interactionManager, conditionsMet: {
                        !showMockPopover
                    }, action: {
                        showMockPopover = true
                    })
                    .padding(.bottom)
                    .popover(isPresented: $showMockPopover) {
                        BlinkButton(name: "hide-popover") {
                            showMockPopover = false
                        } label: {
                            Text("Hide Popover")
                        }.onQuickAction(name: "hide-popover", interactionManager: interactionManager, conditionsMet: {
                            showMockPopover
                        }, action: {
                            showMockPopover = false
                        })
                    }
                    
                    HStack {
                        Text("Typing")
                            .font(.title3)
                        Text(textFieldText)
                    }
                    
                    BlinkTextFieldView(placeholder: "Change Section Title", text: textFieldText)
                        .padding(.bottom)
                }
            }.padding(.horizontal)
        }.environment(\.buttonConfigStyle, buttonsShouldBeRed ? .basicRedAlt : .basic)
    }
}

struct DemoView_Previews: PreviewProvider {
    static var previews: some View {
        DemoView()
            .environmentObject(InteractionManager())
            .environmentObject(GeometryProxyValue())
            .environmentObject(SpeechRecognizerModel())
    }
}
