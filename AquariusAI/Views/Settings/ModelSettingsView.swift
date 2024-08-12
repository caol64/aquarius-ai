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
    @State private var selectedModelFamily: ModelFamily = .ollama
    @State private var selectedModel: Models?
    @State private var showConfirmView = false
    @State private var pageState: SettingsPageState<Models> = .empty
    
    var body: some View {
        VStack {
            modelFamilyPicker
            switch pageState {
            case .empty:
                Spacer()
                ContentUnavailableView {
                    Label("Here is utterly empty.", systemImage: "tray.fill")
                } description: {
                    Button("Add Model") {
                        selectedModel = modelViewModel.onAdd(modelFamily: selectedModelFamily)
                    }
                }
                Spacer()
            case .noItemSelected:
                HStack {
                    sideBar
                        .frame(width: 240)
                    ContentUnavailableView {
                        Text("No Model Selected")
                    }
                    .frame(width: 640)
                }
            case .itemSelected(let model):
                HStack {
                    sideBar
                        .frame(width: 240)
                    ModelEditor(model: model)
                        .frame(width: 640)
                }
            }
        }
        .onAppear {
            updatePageState()
        }
        .onChange(of: selectedModel) {
            updatePageState()
        }
        .onChange(of: selectedModelFamily) {
            updatePageState()
        }
        .onChange(of: modelViewModel.models) {
            updatePageState()
        }
    }
    
    // MARK: - modelFamilyPicker
    @ViewBuilder
    private var modelFamilyPicker: some View {
        @Bindable var modelViewModel = modelViewModel
        Picker("", selection: $selectedModelFamily) {
            ForEach(ModelFamily.allCases) { modelFamily in
                Text(modelFamily.rawValue)
                    .tag(modelFamily)
            }
        }
        .pickerStyle(.segmented)
    }
    
    // MARK: - sideBar
    @MainActor
    @ViewBuilder
    private var sideBar: some View {
        @Bindable var modelViewModel = modelViewModel
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
                    selectedModel = modelViewModel.onAdd(modelFamily: selectedModelFamily)
                }
                
                Button("", systemImage: "minus") {
                    if selectedModel != nil {
                        showConfirmView = true
                    }
                }
                .alert(Text("Are you sure you want to delete the model?"), isPresented: $showConfirmView) {
                    Button("Delete", role: .destructive) {
                        modelViewModel.onDelete(model: selectedModel)
                    }
                }
                
                Spacer()
            }
            .buttonStyle(.accessoryBar)
            .padding(8)
            .background(Color.white)
        }
    }
    
    // MARK: - updatePageState
    @MainActor
    private func updatePageState() {
        if modelViewModel.fetch(modelFamily: selectedModelFamily).isEmpty {
            pageState = .empty
        } else if selectedModel == nil {
            pageState = .noItemSelected
        } else if let model = selectedModel {
            pageState = .itemSelected(model)
        }
    }

}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Models.self, configurations: config)
    container.mainContext.insert(Models(name: "sd3", family: .mlmodel, type: .diffusers))
    container.mainContext.insert(Models(name: "qwen7b", family: .ollama))
    
    return ModelSettingsView()
        .environment(ModelViewModel(errorBinding: ErrorBinding(), modelContext: container.mainContext))
}
