//
//  PluginsSettingsView.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/30.
//

import SwiftUI

struct PluginsSettingsView: View {
    @Environment(PluginViewModel.self) private var pluginViewModel
    @State private var selectedFamily: PluginFamily?
    @State private var selectedPlugin: Plugins?
    
    var body: some View {
        VStack {
            HStack {
                sideBar
                    .frame(width: 240)
                
                editor
                    .frame(width: 640)
            }
        }
        .onChange(of: selectedFamily) {
            if let family = selectedFamily {
                selectedPlugin = pluginViewModel.getAndSave(family: family)
            }
        }
    }
    
    // MARK: - sideBar
    private var sideBar: some View {
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
    }
    
    // MARK: - editor
    @ViewBuilder
    private var editor: some View {
        if let plugin = selectedPlugin {
            PluginEditor(plugin: plugin)
        } else {
            ContentUnavailableView {
                Text("No Plugin Selected")
            }
        }
    }

}

#Preview {
    PluginsSettingsView()
}
