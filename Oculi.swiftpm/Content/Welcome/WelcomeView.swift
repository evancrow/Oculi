//
//  SwiftUIView.swift
//  
//
//  Created by Evan Crow on 4/7/22.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var model: EyeTrackerModel
    @State private var currentPage: WelcomePages = .intro
    
    public let dismiss: () -> Void
    
    private var nextButtonTitle: String {
        switch currentPage {
        case .intro:
            return "Next: Getting Around"
        case .movingAround:
            return "Next: Interacting"
        case .interactions:
            return "Get Started"
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            
            HStack {
                switch currentPage {
                case .intro:
                    IntroView()
                case .movingAround:
                    MovingAroundView()
                case .interactions:
                    InteractingView()
                }
                
                Spacer()
            }.padding(.horizontal)
            
            HStack {
                BlinkButton(name: "welcome-back") {
                    model.endTracking()
                    
                    switch currentPage {
                    case .movingAround:
                        currentPage = .intro
                    case .interactions:
                        currentPage = .movingAround
                    default:
                        break
                    }
                } label: {
                    Text("Back")
                }.disabled(currentPage == .intro)
                
                BlinkButton(name: "welcome-next") {
                    model.endTracking()
                    
                    switch currentPage {
                    case .intro:
                        model.displayBlinkingCalibrationViewIfNeeded()
                        currentPage = .movingAround
                    case .movingAround:
                        currentPage = .interactions
                    case .interactions:
                        dismiss()
                    }
                } label: {
                    Text(nextButtonTitle)
                }
            }.padding(.top)
            
            Spacer()
        }
        .font(.title3)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView() {}
            .environmentObject(InteractionManager())
            .environmentObject(GeometryProxyValue())
    }
}

extension Text {
    func welcomeSectionHeaderStyle() -> some View {
        return self
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding(.bottom)
    }
}
