//
//  AquariusAIApp.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/4/23.
//

import SwiftUI
import SwiftData

@main
struct AquariusAIApp: App {
    @State private var errorBinding: ErrorBinding = ErrorBinding()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Agent.self,
            Endpoint.self,
            Chat.self,
            Message.self,
        ])

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        
        let modelContext = sharedModelContainer.mainContext
        
        EndpointService.shared.configure(with: modelContext)
        AgentService.shared.configure(with: modelContext)
        ChatService.shared.configure(with: modelContext)
        
    }

    var body: some Scene {
        #if os(macOS)
        MenuBarExtra("Aquarius AI", systemImage: "hammer") {
            AppMenu()
        }
        .modelContainer(sharedModelContainer)

        Settings {
            SettingsView()
                .environment(errorBinding)
                .alert(isPresented: errorBinding.showError, error: errorBinding.appError) {}
        }
        .modelContainer(sharedModelContainer)
        #endif
        
        WindowGroup(id: "textGenerate") {
            TextGenerateView()
                .environment(errorBinding)
                .alert(isPresented: errorBinding.showError, error: errorBinding.appError) {}
        }
        .modelContainer(sharedModelContainer)
        
        WindowGroup(id: "chat") {
            ChatView()
                .environment(errorBinding)
                .alert(isPresented: errorBinding.showError, error: errorBinding.appError) {}
        }
        .modelContainer(sharedModelContainer)
        
        WindowGroup(id: "imageGenerate") {
            ImageGenerateView()
                .environment(errorBinding)
                .alert(isPresented: errorBinding.showError, error: errorBinding.appError) {}
        }
        .modelContainer(sharedModelContainer)
    }
}
