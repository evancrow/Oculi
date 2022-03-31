//
//  Preview.swift
//  LiveViewTestApp
//
//  Created by Evan Crow on 3/27/22.
//

import SwiftUI

struct PreviewView: View {
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "arrow.up")
            
            HStack {
                Image(systemName: "arrow.left")
                Text("Try moving your head, while keeping your device still.")
                Image(systemName: "arrow.right")
            }
            
            Image(systemName: "arrow.down")
            
            Spacer()
        }
    }
}

struct PreviewView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewView()
    }
}
