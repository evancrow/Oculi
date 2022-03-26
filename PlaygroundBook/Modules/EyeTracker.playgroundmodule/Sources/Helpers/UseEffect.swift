//
//  UseEffect.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/5/22.
//

import SwiftUI

extension View {
    func useEffect<T: Equatable>(deps: T, perform updater: @escaping (T) -> Void) -> some View {
        self.onChange(of: deps, perform: updater)
            .onAppear { updater(deps) }
    }
}
