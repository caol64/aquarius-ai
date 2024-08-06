//
//  PluginsSettingsView.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/30.
//

import SwiftUI

struct PluginsSettingsView: View {
    @State private var selectedFamily: PluginFamily?
    @State private var pluginViewModel = PluginViewModel.shared
    @State private var selectedPlugin: Plugin?
    
    var body: some View {
        VStack {
            HStack {
                VStack(spacing: 0) {
                    List(selection: $selectedFamily) {
                        Section(header: Text("Plugins")) {
                            ForEach(PluginFamily.allCases) { item in
                                Label(item.rawValue, systemImage: "cube")
                                    .tag(item)
                            }
                        }
                    }
                }
                .frame(width: 240)
                
                VStack {
                    if let plugin = selectedPlugin {
                        PluginEditor(plugin: plugin)
                    } else {
                        ContentUnavailableView {
                            Text("No Plugin Selected")
                        }
                    }
                }
                .frame(width: 640)
            }
        }
        .onChange(of: selectedFamily) {
            onChange()
        }
    }
    
    // MARK: - Actions
    private func onChange() {
        if let family = selectedFamily {
            selectedPlugin = pluginViewModel.getAndSave(family: family)
        }
    }
}

#Preview {
    PluginsSettingsView()
}
