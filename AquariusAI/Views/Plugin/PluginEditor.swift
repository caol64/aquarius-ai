//
//  PluginEditor.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/4.
//

import SwiftUI

struct PluginEditor: View {
    @Environment(ModelViewModel.self) private var modelViewModel
    @State private var selectedModel: Models?
    @Bindable var plugin: Plugins
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Choose a model:")
            List(selection: $selectedModel) {
                ForEach(modelViewModel.models.grouped().sorted(by: { $0.key < $1.key }), id: \.key) { family, models in
                    Section(header: Text(family)) {
                        ForEach(models) { model in
                            Label(model.name, systemImage: "cube")
                                .tag(model)
                        }
                    }
                }
            }
        }
        .onAppear() {
            onFetch()
        }
        .onChange(of: selectedModel) {
            plugin.modelId = selectedModel?.id
            plugin.modelName = selectedModel?.name
        }
        .onChange(of: plugin) {
            selectedModel = nil
            onFetch()
        }
    }
    
    // MARK: - onFetch
    @MainActor
    private func onFetch() {
        if let id = plugin.modelId {
            selectedModel = modelViewModel.get(id: id)
        }
    }
}
