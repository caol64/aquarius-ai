//
//  PluginEditor.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/4.
//

import SwiftUI

struct PluginEditor: View {
    @State private var endpointViewModel = EndpointViewModel.shared
    @State private var selectedEndpoint: Endpoint?
    @Bindable var plugin: Plugin
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Choose a model:")
            List(selection: $selectedEndpoint) {
                ForEach(endpointViewModel.endpoints.grouped().sorted(by: { $0.key < $1.key }), id: \.key) { family, models in
                    Section(header: Text(family)) {
                        ForEach(models) { model in
                            Label(model.name, systemImage: "cube")
                                .tag(model)
                        }
                    }
                }
            }
        }
        .task {
            onFetch()
        }
        .onChange(of: selectedEndpoint) {
            plugin.endpointId = selectedEndpoint?.id
        }
        .onChange(of: plugin) {
            selectedEndpoint = nil
            onFetch()
        }
    }
    
    // MARK: - Actions
    private func onFetch() {
        if let id = plugin.endpointId {
            selectedEndpoint = endpointViewModel.get(id: id)
        }
    }
}
