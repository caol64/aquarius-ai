//
//  SettingsView.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/1.
//

import SwiftUI

struct SettingsView: View {
    private enum Tabs: String {
        case models, knowledges
    }
    var body: some View {
        TabView {
            ModelSettingsView()
                .tabItem {
                    Label(Tabs.models.rawValue.capitalized, systemImage: "square.stack.3d.forward.dottedline")
                }
                .tag(Tabs.models)
                .frame(width: 880, height: 480)
            KnowledgeSettingsView()
                .tabItem {
                    Label(Tabs.knowledges.rawValue.capitalized, systemImage: "graduationcap")
                }
                .tag(Tabs.knowledges)
                .frame(width: 880, height: 480)
        }
        .padding()
    }
}
