//
//  ErrorView.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/6/22.
//

import SwiftUI

struct ErrorView: View {
    let error: String
    var buttonText: String? = nil
    var buttonAction: (() -> Void)? = nil
    
    @ViewBuilder
    var button: some View {
        if let buttonAction = buttonAction, let buttonText = buttonText {
            Button {
                buttonAction()
            } label: {
                Text(buttonText)
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(
                        Color.blue
                            .cornerRadius(UXDefaults.backgroundCornerRadius)
                    )
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 14) {
                Text(":(")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                   
                Text(error)
            }
                
            button
            
        }
        .padding()
        .foregroundColor(.blue)
        .background(
            Color.blue
                .opacity(UXDefaults.backgroundOpacity)
                .cornerRadius(UXDefaults.backgroundCornerRadius)
        ).padding(.horizontal)
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(
            error: "Something went wrong here, now this text is extra long as well.",
            buttonText: "Try Again",
            buttonAction: {}
        )
    }
}
