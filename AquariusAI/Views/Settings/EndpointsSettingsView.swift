//
//  EndpointsSettingsView.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/1.
//

import SwiftUI
import SwiftData

struct EndpointsSettingsView: View {
    @Environment(ErrorBinding.self) private var errorBinding
    @State private var showConfirmView = false
    @State private var selectedModelFamily: ModelFamily = .diffusers
    @State private var endpoints: [Endpoint] = []
    @State private var selectedEndpoint: Endpoint?
    private let endpointService = EndpointService.shared
    
    
    var body: some View {
        VStack {
            Picker("", selection: $selectedModelFamily) {
                ForEach(ModelFamily.allCases) { modelFamily in
                    Text(modelFamily.rawValue)
                        .tag(modelFamily)
                }
            }
            .onChange(of: selectedModelFamily) {
                Task {
                    await onFetch()
                }
            }
            .pickerStyle(.segmented)
            
            if endpoints.isEmpty {
                VStack {
                    Text("Please add some models first.")
                        .padding(.top, 4)
                        .font(.title)
                    
                    Button("Add Model") {
                        onAdd(selectedModelFamily)
                    }
                }
                .frame(width: 840, height: 480)
            } else {
                HStack {
                    VStack(spacing: 0) {
                        List(selection: $selectedEndpoint) {
                            Section(header: Text("Models")) {
                                ForEach(endpoints) { model in
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
                    .frame(width: 200, height: 480)
                    
                    if let endpoint = selectedEndpoint {
                        EndpointsEditor(endpoint: endpoint)
                            .frame(width: 640, height: 480)
                    } else {
                        ContentUnavailableView {
                            Text("No Model Selected")
                        }
                        .frame(width: 640, height: 480)
                    }
                }
            }
        }
        .task {
            await onFetch()
        }
    }
    
    // MARK: - Actions
    private func onAdd(_ modelFamily: ModelFamily) {
        let endpoint = Endpoint(name: "new model", modelFamily: selectedModelFamily)
        Task {
            await endpointService.save(endpoint)
            await onFetch(selected: endpoint)
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
                await endpointService.delete(selectedEndpoint)
                await onFetch()
            }
        }
    }
    
    private func onFetch(selected: Endpoint? = nil) async {
        do {
            endpoints = try await endpointService.fetch(modelFamily: selectedModelFamily)
            if selected != nil {
                selectedEndpoint = selected
            } else if !endpoints.isEmpty {
                selectedEndpoint = endpoints.first
            }
        } catch {
            errorBinding.appError = AppError.dbError(description: error.localizedDescription)
            print(error)
        }
    }
    
}


#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Endpoint.self, configurations: config)
    container.mainContext.insert(Endpoint(name: "sd3", modelFamily: .diffusers))
    container.mainContext.insert(Endpoint(name: "qwen7b", modelFamily: .ollama))
    EndpointService.shared.configure(with: container.mainContext)
    
    return EndpointsSettingsView()
        .environment(ErrorBinding())
}
