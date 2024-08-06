//
//  AppMenu.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/1.
//

import SwiftUI

struct AppMenu: View {
    
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("Chat") {
            openChat()
        }
        Button("Text Generation") {
            openTextGenerate()
        }
        Button("Image Generation") {
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
    
    func openChat() {
        openWindow(id: "chat")
        NSApp.activate(ignoringOtherApps: true)
    }
    func openTextGenerate() {
        openWindow(id: "textGenerate")
        NSApp.activate(ignoringOtherApps: true)
    }
    func openImageGenerate() {
        openWindow(id: "imageGenerate")
        NSApp.activate(ignoringOtherApps: true)
    }
    func quit() {
        NSApplication.shared.terminate(nil)
    }
}

#Preview {
    AppMenu()
}
