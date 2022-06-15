//
//  Knick_KnackApp.swift
//  Knick Knack
//
//  Created by Jordan Huffaker on 2/1/22.
//

import SwiftUI

@main
struct Knick_KnackApp: App {
    var body: some Scene {
        WindowGroup {
                ContentView()
                    .fixedSize()
                    .onReceive(NotificationCenter.default.publisher(for: NSApplication.willUpdateNotification), perform: { _ in
                        for window in NSApplication.shared.windows {
                            window.standardWindowButton(.zoomButton)?.isEnabled = false
                        }
                    })
            }
    }
}
