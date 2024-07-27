//
//  SettingsView.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/1.
//

import SwiftUI

struct SettingsView: View {
    private enum Tabs: Hashable {
        case models, agents
    }
    var body: some View {
        TabView {
            ModelsSettingsView()
                .tabItem {
                    Label("Models", systemImage: "gear")
                }
                .tag(Tabs.models)
            AgentsSettingsView()
                .tabItem {
                    Label("Agents", systemImage: "star")
                }
                .tag(Tabs.agents)
        }
        .padding()
    }
}
