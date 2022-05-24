//
//  IntroView.swift
//  
//
//  Created by Evan Crow on 4/8/22.
//

import SwiftUI

struct IntroView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Welcome to Oculi!")
                .welcomeSectionHeaderStyle()
            
            VStack(alignment: .leading) {
                Text("Today,")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.bottom)
                
                Text("1 in 50 people suffer from paralysis. For some of them, interacting with technology is something close to impossible. All of that is about to change.")
            }
           
            Text("Oculi is the world's first, (soon to be) open-source API, any developer can add to their app, that allows users to interact with their phone using only their head and eyes.")
            Text("This app is a demo of just how powerful, and easy, Oculi is to use.")
            
            Text("Oculi is best experinced in a well-lit area, with sound 🔊.")
                .italic()
                .padding(.top)
            
            Spacer()
        }
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
