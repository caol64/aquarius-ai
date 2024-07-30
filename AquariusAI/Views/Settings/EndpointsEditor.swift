//
//  EndpointsEditor.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/24.
//

import SwiftUI

struct EndpointsEditor: View {
    @Environment(ErrorBinding.self) private var errorBinding
    @State private var showFileImporter: Bool = false
    @State private var remoteModels: [String] = []
    @Bindable var endpoint: Endpoint
    
    var body: some View {
        VStack {
            Form {
                TextField("Model Name", text: $endpoint.name)
                
                if endpoint.modelFamily.needAppKey {
                    TextField("AppKey", text: $endpoint.appkey)
                        .padding(.top, 4)
                }
                
                if !endpoint.modelFamily.isLocal {
                    HStack(alignment: .bottom) {
                        TextField("Host", text: $endpoint.host)
                            .padding(.top, 4)
                        
                        Button("Refresh...") {
                            onSync()
                        }
                    }
                    
                    Picker("Model", selection: $endpoint.endpoint) {
                        ForEach(remoteModels, id: \.self) { model in
                            Text(model)
                                .lineLimit(1)
                                .tag(model)
                        }
                    }
                    .onChange(of: endpoint.endpoint) {
                        onRemoteModelChange()
                    }
                    .padding(.top, 4)
                } else {
                    HStack(alignment: .bottom) {
                        TextField("Local Path", text: $endpoint.endpoint)
                            .padding(.top, 4)
                            .disabled(true)
                        
                        Button("Select...") {
                            showFileImporter = true
                        }
                        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: endpoint.modelFamily.isLocalFolder ? [.folder]: [.mlmodel, .mlmodelc]) { result in
                            switch result {
                            case .success(let directory):
                                endpoint.endpoint = directory.path()
                                endpoint.name = directory.lastPathComponent
                                let gotAccess = directory.startAccessingSecurityScopedResource()
                                if !gotAccess {
                                    errorBinding.appError = AppError.directoryNotReadable(path: directory.path())
                                }
                                saveBookmarkData(for: directory, endpoint: endpoint)
                                directory.stopAccessingSecurityScopedResource()
                            case .failure(let error):
                                errorBinding.appError = AppError.unexpected(description: error.localizedDescription)
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
                remoteModels = try await OllamaService.shared.fetchModels(host: endpoint.host)
                if endpoint.endpoint.isEmpty && !remoteModels.isEmpty {
                    endpoint.endpoint = remoteModels.first!
                }
            } catch {
                errorBinding.appError = AppError.dbError(description: error.localizedDescription)
            }
        }
    }
    
    private func onRemoteModelChange() {
        if !endpoint.endpoint.isEmpty {
            endpoint.name = endpoint.endpoint
        }
    }
    
    
}
