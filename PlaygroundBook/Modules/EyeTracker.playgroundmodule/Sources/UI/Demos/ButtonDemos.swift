//
//  ButtonDemos.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/7/22.
//

import SwiftUI

struct ButtonDemos: View {
    @State var buttonsShouldBeRed = false
    
    var body: some View {
        BlinkButton(
            config: buttonsShouldBeRed ? .basicRedAlt : .basic
        ) {
            print("Blink Button Triggered")
            buttonsShouldBeRed.toggle()
        } label: {
            Text("Two Blink Interaction Button")
        }
      
        LongBlinkButton(
            duration: 2,
            config: buttonsShouldBeRed ? .basicRedAlt : .basic
        ) {
            print("Long Blink Button Triggered")
            buttonsShouldBeRed.toggle()
        } label: {
            Text("Long Blink Interaction Button (2 sec)")
        }.padding(.bottom)
    }
}

struct ButtonDemos_Previews: PreviewProvider {
    static var previews: some View {
        ButtonDemos()
    }
}
