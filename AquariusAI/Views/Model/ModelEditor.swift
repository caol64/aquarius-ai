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
                
                if model.modelFamily.needAppKey {
                    TextField("AppKey", text: $model.appkey ?? "")
                        .padding(.top, 4)
                }
                
                if !model.modelFamily.isLocal {
                    HStack(alignment: .bottom) {
                        TextField("Host", text: $model.host ?? "")
                            .padding(.top, 4)
                        
                        Button("Refresh...") {
                            onSync()
                        }
                    }
                    
                    Picker("Model", selection: $model.endpoint) {
                        ForEach(remoteModels, id: \.self) { model in
                            Text(model)
                                .lineLimit(1)
                                .tag(model)
                        }
                    }
                    .onChange(of: model.endpoint) {
                        model.name = model.endpoint ?? ""
                    }
                    .onChange(of: remoteModels) {
                        if let remoteModel = remoteModels.first {
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
                        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: model.modelFamily.isLocalFolder ? [.folder]: [.mlmodel, .mlmodelc]) { result in
                            switch result {
                            case .success(let directory):
                                model.endpoint = directory.path()
                                model.name = directory.lastPathComponent
                                let gotAccess = directory.startAccessingSecurityScopedResource()
                                if !gotAccess {
                                    modelViewModel.handleError(error: AppError.directoryNotReadable(path: directory.path()))
                                }
                                do {
                                    model.bookmark = try createBookmarkData(for: directory)
                                } catch {
                                    modelViewModel.handleError(error: error)
                                }
                                directory.stopAccessingSecurityScopedResource()
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
        if let host = model.host {
            Task {
                do {
                    remoteModels = try await OllamaService.shared.fetchModels(host: host)
                } catch {
                    await modelViewModel.handleError(error: error)
                }
            }
        }
    }
    
}
