//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  Instantiates a live view and passes it to the PlaygroundSupport framework.
//

import BookCore
import PlaygroundSupport
import SwiftUI

// Instantiate a new instance of the live view from BookCore and pass it to PlaygroundSupport.
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = instantiateLiveView(with: .test)
