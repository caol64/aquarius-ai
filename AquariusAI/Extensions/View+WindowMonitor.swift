//
//  View+WindowMonitor.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/13.
//

import SwiftUI

extension View {
    func monitorWindowFocus(for page: Page, appState: AppState) -> some View {
        self
            .onAppear {
                NotificationCenter.default.addObserver(forName: NSWindow.didBecomeKeyNotification, object: nil, queue: .main) { notification in
                    if let window = notification.object as? NSWindow, let id = window.identifier, id.rawValue.contains(page.rawValue) {
                        appState.activePage(page: page)
                    }
                }
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(self)
            }
    }
}
