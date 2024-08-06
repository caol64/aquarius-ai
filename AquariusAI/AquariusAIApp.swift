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
            Endpoint.self,
            Plugin.self,
            Knowledge.self,
//            Chat.self,
//            Message.self,
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
        EndpointViewModel.shared.configure(modelContext: modelContext, errorBinding: errorBinding)
        KnowledgeViewModel.shared.configure(modelContext: modelContext, errorBinding: errorBinding)
        PluginViewModel.shared.configure(modelContext: modelContext, errorBinding: errorBinding)
        Task {
            await EndpointViewModel.shared.fetch()
        }
    }

    var body: some Scene {
        #if os(macOS)
        MenuBarExtra("Aquarius AI", systemImage: "hammer") {
            AppMenu()
        }

        Settings {
            SettingsView()
                .environment(errorBinding)
                .alert(isPresented: errorBinding.showError, error: errorBinding.appError) {}
        }
        #endif
        
        WindowGroup(id: "textGenerate") {
            TextGenerationView()
                .environment(errorBinding)
                .alert(isPresented: errorBinding.showError, error: errorBinding.appError) {}
        }
        
        WindowGroup(id: "chat") {
            ChatView()
                .environment(errorBinding)
                .alert(isPresented: errorBinding.showError, error: errorBinding.appError) {}
        }
        
        WindowGroup(id: "imageGenerate") {
            ImageGenerationView()
                .environment(errorBinding)
                .alert(isPresented: errorBinding.showError, error: errorBinding.appError) {}
        }
    }
}
