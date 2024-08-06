//
//  EndpointsSettingsView.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/1.
//

import SwiftUI
import SwiftData

struct EndpointsSettingsView: View {
    @State private var showConfirmView = false
    @State private var selectedModelFamily: ModelFamily = .ollama
    @State private var selectedEndpoint: Endpoint?
    @State private var endpointViewModel = EndpointViewModel.shared
    
    var body: some View {
        VStack {
            Picker("", selection: $selectedModelFamily) {
                ForEach(ModelFamily.allCases) { modelFamily in
                    Text(modelFamily.rawValue)
                        .tag(modelFamily)
                }
            }
            .onChange(of: selectedModelFamily) {
                onChange()
            }
            .pickerStyle(.segmented)
            
            if endpointViewModel.fetch(modelFamily: selectedModelFamily).isEmpty {
                Spacer()
                ContentUnavailableView {
                    Label("Here is utterly empty.", systemImage: "tray.fill")
                } description: {
                    Button("Add Model") {
                        onAdd(selectedModelFamily)
                    }
                }
                Spacer()
            } else {
                HStack {
                    VStack(spacing: 0) {
                        List(selection: $selectedEndpoint) {
                            Section(header: Text("Models")) {
                                ForEach(endpointViewModel.fetch(modelFamily: selectedModelFamily)) { model in
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
                                onConfirmDelete()
                            }
                            .alert(Text("Are you sure you want to delete the model?"), isPresented: $showConfirmView) {
                                Button("Delete", role: .destructive) {
                                    onDelete()
                                }
                            }
                            
                            Spacer()
                        }
                        .buttonStyle(.accessoryBar)
                        .padding(8)
                        .background(Color.white)
                        
                    }
                    .frame(width: 240)
                    
                    VStack {
                        if let endpoint = selectedEndpoint {
                            EndpointsEditor(endpoint: endpoint)
                        } else {
                            ContentUnavailableView {
                                Text("No Model Selected")
                            }
                        }
                    }
                    .frame(width: 640)
                }
            }
        }
        .task {
            await endpointViewModel.fetch()
        }
    }
    
    // MARK: - Actions
    private func onAdd(_ modelFamily: ModelFamily) {
        let endpoint = Endpoint(name: "new model", modelFamily: selectedModelFamily)
        Task {
            await endpointViewModel.save(endpoint)
            onChange(selected: endpoint)
        }
    }
    
    private func onConfirmDelete() {
        if selectedEndpoint != nil {
            showConfirmView = true
        }
    }
    
    private func onDelete() {
        if let selectedEndpoint = selectedEndpoint {
            Task {
                await endpointViewModel.delete(selectedEndpoint)
                onChange()
            }
        }
    }
    
    private func onChange(selected: Endpoint? = nil) {
        if selected != nil {
            selectedEndpoint = selected
        } else {
            let endpoints = endpointViewModel.fetch(modelFamily: selectedModelFamily)
            if !endpoints.isEmpty {
                selectedEndpoint = endpoints.first
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Endpoint.self, configurations: config)
    container.mainContext.insert(Endpoint(name: "sd3", modelFamily: .diffusers))
    container.mainContext.insert(Endpoint(name: "qwen7b", modelFamily: .ollama))
    let errorBinding = ErrorBinding()
    EndpointViewModel.shared.configure(modelContext: container.mainContext, errorBinding: errorBinding)
    
    return EndpointsSettingsView()
        .environment(errorBinding)
}
