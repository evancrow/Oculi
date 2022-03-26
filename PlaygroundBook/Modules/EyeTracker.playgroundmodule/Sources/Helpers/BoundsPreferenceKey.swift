//
//  BoundsPreferenceKey.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/5/22.
//

import SwiftUI

struct BoundsPreferenceKey: PreferenceKey {
    typealias Value = Anchor<CGRect>?

    static var defaultValue: Value = nil

    static func reduce(
        value: inout Value,
        nextValue: () -> Value
    ) {
        value = nextValue()
    }
}
