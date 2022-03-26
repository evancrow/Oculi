//
//  GeometryReaderKey.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/5/22.
//

import SwiftUI


class GeometryProxyValue: ObservableObject, Equatable {
    let id = UUID()
    
    @Published var geom: GeometryProxy? = nil {
        didSet {
            geomUpdated += 1
        }
    }
    /// Since `GeometryProxy` does not conform to equatable,
    /// `geomUpdated` tells Combine listeners the object has changed.
    @Published var geomUpdated = 0
    
    static func == (lhs: GeometryProxyValue, rhs: GeometryProxyValue) -> Bool {
        lhs.id == rhs.id
    }
}
