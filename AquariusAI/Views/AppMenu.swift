//
//  AppMenu.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/1.
//

import SwiftUI

struct AppMenu: View {
    
    @Environment(\.openWindow) private var openWindow
    @Environment(AppState.self) private var appState

    var body: some View {
        Button(Page.text.rawValue.capitalized) {
            openTextGenerate()
        }
        Button(Page.image.rawValue.capitalized) {
            openImageGenerate()
        }
        
        Divider()
        SettingsLink(
            label: {
                Text("Settings...")
            }
        )
        Button("Quit") {
            quit()
        }
    }
    
    func openTextGenerate() {
        if !appState.openedWindows.contains(.text) {
            openWindow(id: Page.text.rawValue)
        }
        NSApp.activate(ignoringOtherApps: true)
    }
    func openImageGenerate() {
        if !appState.openedWindows.contains(.image) {
            openWindow(id: Page.image.rawValue)
        }
        NSApp.activate(ignoringOtherApps: true)
    }
    func quit() {
        NSApplication.shared.terminate(nil)
    }
}

#Preview {
    AppMenu()
}
