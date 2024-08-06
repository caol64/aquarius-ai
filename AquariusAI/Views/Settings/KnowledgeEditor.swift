//
//  KnowledgeEditor.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/2.
//

import SwiftUI

struct KnowledgeEditor: View {
    @Environment(ErrorBinding.self) private var errorBinding
    @Bindable var knowledge: Knowledge
    @State private var showFileImporter: Bool = false
    @State private var selectedChunkSize: Int = 1024
    @State private var topK: Float = 2
    @State private var embeddingEndpoint: Endpoint?
    @State private var pluginViewModel = PluginViewModel.shared
    @State private var endpointViewModel = EndpointViewModel.shared
    private let chunkSizes = [256, 512, 1024, 2048, 4096, 8192]
    
    var body: some View {
        VStack {
            Form {
                TextField("Name", text: $knowledge.name)
                
                HStack(alignment: .bottom) {
                    TextField("Knowledge File", text: $knowledge.file)
                        .disabled(true)
                    
                    Button("Select...") {
                        showFileImporter = true
                    }
                    .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.text]) { result in
                        switch result {
                        case .success(let directory):
                            knowledge.file = directory.path()
                            let gotAccess = directory.startAccessingSecurityScopedResource()
                            if !gotAccess {
                                errorBinding.appError = AppError.directoryNotReadable(path: directory.path())
                            }
                            do {
                                knowledge.bookmark = try createBookmarkData(for: directory)
                                knowledge.knowledgeStatus = .ready
                            } catch {
                                errorBinding.appError = AppError.unexpected(description: error.localizedDescription)
                            }
                            directory.stopAccessingSecurityScopedResource()
                        case .failure(let error):
                            errorBinding.appError = AppError.unexpected(description: error.localizedDescription)
                        }
                    }
                }
                .padding(.top, 4)
                
                Picker("Chunk Size", selection: $selectedChunkSize) {
                    ForEach(chunkSizes, id: \.self) { chunkSize in
                        Text(String(chunkSize))
                            .tag(chunkSize)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.top, 4)
                
                LabeledContent {
                    HStack {
                        Slider(value: $topK, in: 1...10, step: 1)
                        Text(String(format: "%.0f", topK))
                    }
                } label: {
                    Text("Top K")
                }
                .padding(.top, 4)
                
                LabeledContent {
                    Text("\(embeddingEndpoint?.name ?? "")")
                } label: {
                    Text("Embedding Plugin")
                }
                .padding(.top, 4)
                
                LabeledContent {
                    Text("\(knowledge.status)")
                } label: {
                    Text("Status")
                }
                .padding(.top, 4)
                
                Button("Build Index") {
                    onBuild()
                }
                .disabled(knowledge.knowledgeStatus == .inited)
                .buttonStyle(.borderedProminent)
                .rightAligned()
                .padding(.top, 4)
                
                Spacer()
                
            }
            .padding()
        }
        .task {
            onFetch()
        }
    }
    
    // MARK: - Actions
    private func onFetch() {
        let embeddingPlugin = pluginViewModel.get(family: .embedding)
        if let plugin = embeddingPlugin, let endpointId = plugin.endpointId {
            embeddingEndpoint = endpointViewModel.get(id: endpointId)
        }
    }
    
    private func onBuild() {
        if knowledge.knowledgeStatus == .inited {
            errorBinding.appError = AppError.bizError(description: "Please choose the knowledge file.")
        }
        guard let endpoint = embeddingEndpoint else {
            errorBinding.appError = AppError.bizError(description: "Please setup a embedding plugin first.")
            return
        }
        Task {
            do {
                try await KnowledgeService.shared.buildIndex(knowledge: knowledge, endpoint: endpoint)
            } catch {
                errorBinding.appError = AppError.bizError(description: error.localizedDescription)
            }
        }
    }

}
