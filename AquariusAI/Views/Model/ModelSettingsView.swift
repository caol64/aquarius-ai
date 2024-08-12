//
//  ModelSettingsView.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/1.
//

import SwiftUI
import SwiftData

struct ModelSettingsView: View {
    @Environment(ModelViewModel.self) private var modelViewModel
    @State private var showConfirmView = false
    @State private var selectedModelFamily: ModelFamily = .ollama
    @State private var selectedModel: Models?
    
    @ViewBuilder
    var body: some View {
        modelFamilyPicker
        if modelViewModel.fetch(modelFamily: selectedModelFamily).isEmpty {
            emptyView
        } else {
            HStack {
                sideBar
                    .frame(width: 240)
                editor
                    .frame(width: 640)
            }
        }
    }
    
    // MARK: - modelFamilyPicker
    @MainActor
    private var modelFamilyPicker: some View {
        Picker("", selection: $selectedModelFamily) {
            ForEach(ModelFamily.allCases) { modelFamily in
                Text(modelFamily.rawValue)
                    .tag(modelFamily)
            }
        }
        .onChange(of: selectedModelFamily) {
            selectedModel = modelViewModel.selectDefault(modelFamily: selectedModelFamily)
        }
        .pickerStyle(.segmented)
    }
    
    // MARK: - emptyView
    @ViewBuilder
    @MainActor
    private var emptyView: some View {
        Spacer()
        ContentUnavailableView {
            Label("Here is utterly empty.", systemImage: "tray.fill")
        } description: {
            Button("Add Model") {
                onAdd(selectedModelFamily)
            }
        }
        Spacer()
    }
    
    // MARK: - sideBar
    @MainActor
    private var sideBar: some View {
        VStack(spacing: 0) {
            List(selection: $selectedModel) {
                Section(header: Text("Models")) {
                    ForEach(modelViewModel.fetch(modelFamily: selectedModelFamily)) { model in
                        Label(model.name, systemImage: "cube")
                            .tag(model)
                    }
                }
            }
            
            HStack {
                Button("", systemImage: "plus") {
                    onAdd(selectedModelFamily)
                }
                
                Button("", systemImage: "minus") {
                    if selectedModel != nil {
                        showConfirmView = true
                    }
                }
                .alert(Text("Are you sure you want to delete the model?"), isPresented: $showConfirmView) {
                    Button("Delete", role: .destructive) {
                        if let selectedModel = selectedModel {
                            modelViewModel.delete(selectedModel)
                            self.selectedModel = modelViewModel.selectDefault(modelFamily: selectedModelFamily)
                        }
                    }
                }
                
                Spacer()
            }
            .buttonStyle(.accessoryBar)
            .padding(8)
            .background(Color.white)
        }
    }
    
    // MARK: - editor
    @ViewBuilder
    private var editor: some View {
        if let model = selectedModel {
            ModelEditor(model: model)
        } else {
            ContentUnavailableView {
                Text("No Model Selected")
            }
        }
    }
    
    // MARK: - onAdd
    @MainActor
    private func onAdd(_ modelFamily: ModelFamily) {
        let model = Models(name: "new model", modelFamily: selectedModelFamily)
        modelViewModel.save(model)
        selectedModel = model
    }

}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Models.self, configurations: config)
    container.mainContext.insert(Models(name: "sd3", modelFamily: .diffusers))
    container.mainContext.insert(Models(name: "qwen7b", modelFamily: .ollama))
    
    return ModelSettingsView()
        .environment(ModelViewModel(errorBinding: ErrorBinding(), modelContext: container.mainContext))
}
