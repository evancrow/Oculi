//
//  Cursor.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/6/22.
//

import SwiftUI

struct Cursor: View {
    var offset: CGPoint
    
    var body: some View {
        Circle()
            .foregroundColor(.blue)
            .frame(width: UXDefaults.cursorHeight, height: UXDefaults.cursorHeight)
            .offset(x: offset.x, y: offset.y)
    }
}

struct Cursor_Previews: PreviewProvider {
    static var previews: some View {
        Cursor(offset: CGPoint(x: 0, y: 0))
    }
}
