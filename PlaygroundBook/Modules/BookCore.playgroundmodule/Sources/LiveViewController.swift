//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  A source file which is part of the auxiliary module named "BookCore".
//  Provides the implementation of the "always-on" live view.
//

import UIKit
import SwiftUI
import EyeTracker
import PlaygroundSupport

public enum LiveViewScene {
    case preview
    case test
}

@objc(BookCore_LiveViewController)
public class LiveViewController: UIViewController {
    var scene: LiveViewScene?
    
    // MARK: - UIViewController Methods
    public override func viewDidLoad() {
        guard let scene = scene else {
            return
        }
        
        switch scene {
        case .preview:
            showSwiftUIView {
                Text("Buttons")
            }
        case .test:
            showSwiftUIView {
                Text("Buttons")
            }
        }
    }
    
    // MARK: - SwiftUI View Load Methods
    private func showSwiftUIView<Content: View>(_ view: () -> Content, wrapInInteractionViewWrapper: Bool = true) {
        let hostingController = UIHostingController(rootView: InteractionViewWrapper { view() })
        guard let hostingView = hostingController.view else {
            return
        }
        
        self.view.addSubview(hostingView)
        
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        hostingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        hostingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        hostingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
    
    // MARK: - init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - Playground Live View Support
extension LiveViewController: PlaygroundLiveViewMessageHandler, PlaygroundLiveViewSafeAreaContainer {
    /*
    public func liveViewMessageConnectionOpened() {
        // Implement this method to be notified when the live view message connection is opened.
        // The connection will be opened when the process running Contents.swift starts running and listening for messages.
    }
    */

    /*
    public func liveViewMessageConnectionClosed() {
        // Implement this method to be notified when the live view message connection is closed.
        // The connection will be closed when the process running Contents.swift exits and is no longer listening for messages.
        // This happens when the user's code naturally finishes running, if the user presses Stop, or if there is a crash.
    }
    */

    public func receive(_ message: PlaygroundValue) {
        // Implement this method to receive messages sent from the process running Contents.swift.
        // This method is *required* by the PlaygroundLiveViewMessageHandler protocol.
        // Use this method to decode any messages sent as PlaygroundValue values and respond accordingly.
    }
}
