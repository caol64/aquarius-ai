//
//  SettingsView.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/1.
//

import SwiftUI

struct SettingsView: View {
    private enum Tabs: String, Hashable {
        case endpoints, agents
    }
    var body: some View {
        TabView {
            EndpointsSettingsView()
                .tabItem {
                    Label(Tabs.endpoints.rawValue.capitalized, systemImage: "gear")
                }
                .tag(Tabs.endpoints)
            AgentsSettingsView()
                .tabItem {
                    Label(Tabs.agents.rawValue.capitalized, systemImage: "star")
                }
                .tag(Tabs.agents)
        }
        .padding()
    }
}
