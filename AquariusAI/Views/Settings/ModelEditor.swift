//
//  ModelEditor.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/24.
//

import SwiftUI

struct ModelEditor: View {
    @Environment(ModelViewModel.self) private var modelViewModel
    @State private var showFileImporter: Bool = false
    @State private var remoteModels: [String] = []
    @Bindable var model: Models
    
    var body: some View {
        VStack {
            Form {
                TextField("Name", text: $model.name)
                
                Picker("Model Family", selection: $model.family) {
                    ForEach(model.type.supportedFamily, id: \.self) { family in
                        Text(family.rawValue)
                            .lineLimit(1)
                            .tag(family)
                    }
                }
                .padding(.top, 4)
                
                if model.family.needAppKey {
                    TextField("AppKey", text: $model.appkey ?? "")
                        .padding(.top, 4)
                }
                
                if !model.family.isLocal {
                    HStack(alignment: .bottom) {
                        TextField("Host", text: $model.host)
                            .padding(.top, 4)
                        
                        Button("Refresh...") {
                            onSync()
                        }
                    }
                    
                    Picker("Model", selection: $model.endpoint) {
                        ForEach(remoteModels, id: \.self) { model in
                            Text(model)
                                .lineLimit(1)
                                .tag(Optional(model))
                        }
                    }
                    .onChange(of: model.endpoint) {
                        if let endpoint = model.endpoint {
                            model.name = endpoint
                        }
                    }
                    .onChange(of: remoteModels) {
                        if let remoteModel = remoteModels.first, model.endpoint == nil {
                            model.endpoint = remoteModel
                        }
                    }
                    .padding(.top, 4)
                } else {
                    HStack(alignment: .bottom) {
                        TextField("Local Path", text: $model.endpoint ?? "")
                            .padding(.top, 4)
                            .disabled(true)
                        
                        Button("Select...") {
                            showFileImporter = true
                        }
                        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.folder, .mlmodel, .mlmodelc]) { result in
                            switch result {
                            case .success(let directory):
                                modelViewModel.handleModelPath(model: model, directory: directory)
                            case .failure(let error):
                                modelViewModel.handleError(error: error)
                            }
                        }
                    }
                }
                
                Spacer()
                
            }
            .padding()
        }
    }
    
    // MARK: - Actions
    private func onSync() {
        Task {
            do {
                remoteModels = try await model.sync()
            } catch {
                await modelViewModel.handleError(error: error)
            }
        }
    }
    
}
