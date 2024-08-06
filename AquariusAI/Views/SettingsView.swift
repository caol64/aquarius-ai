//
//  SettingsView.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/1.
//

import SwiftUI

struct SettingsView: View {
    private enum Tabs: String {
        case models, plugins, knowledges
    }
    var body: some View {
        TabView {
            EndpointsSettingsView()
                .tabItem {
                    Label(Tabs.models.rawValue.capitalized, systemImage: "square.stack.3d.forward.dottedline")
                }
                .tag(Tabs.models)
                .frame(width: 880, height: 480)
            PluginsSettingsView()
                .tabItem {
                    Label(Tabs.plugins.rawValue.capitalized, systemImage: "gearshape.2")
                }
                .tag(Tabs.plugins)
                .frame(width: 880, height: 480)
            KnowledgeSettingsView()
                .tabItem {
                    Label(Tabs.knowledges.rawValue.capitalized, systemImage: "graduationcap")
                }
                .tag(Tabs.plugins)
                .frame(width: 880, height: 480)
        }
        .padding()
    }
}
