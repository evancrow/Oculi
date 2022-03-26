//
//  DemoView.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/7/22.
//

import SwiftUI

enum DemoViews: Int, CaseIterable {
    case buttons = 0
    case quickActions = 1
}

struct DemoView: View {
    @State var currentDemo: DemoViews = .buttons
    
    @ViewBuilder
    var demoView: some View {
        switch currentDemo {
        case .buttons:
            ButtonDemos()
        case .quickActions:
            QuickActionDemos()
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                BlinkButton {
                    if let demoView = DemoViews(rawValue: currentDemo.rawValue - 1) {
                        currentDemo = demoView
                    }
                } label: {
                    Image(systemName: "arrow.left")
                }.disabled(currentDemo.rawValue == 0)
                
                BlinkButton {
                    if let demoView = DemoViews(rawValue: currentDemo.rawValue + 1) {
                        currentDemo = demoView
                    }
                } label: {
                    Image(systemName: "arrow.right")
                }.disabled(currentDemo.rawValue == DemoViews.allCases.count - 1)
            }.padding(.bottom)
           
            demoView
        }.padding()
    }
}

struct DemoView_Previews: PreviewProvider {
    static var previews: some View {
        DemoView()
            .environmentObject(InteractionManager())
            .environmentObject(GeometryProxyValue())
    }
}
