//
//  KnowledgeEditor.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/2.
//

import SwiftUI

struct KnowledgeEditor: View {
    @Environment(KnowledgeViewModel.self) private var knowledgeViewModel
    @Environment(ModelViewModel.self) private var modelViewModel
    @Bindable var knowledge: Knowledges
    @State private var showFileImporter: Bool = false
    private let chunkSizes = [256, 512, 1024, 2048, 4096, 8192]
    
    var body: some View {
        VStack {
            Form {
                TextField("Name", text: $knowledge.name)
                
                HStack(alignment: .bottom) {
                    TextField("Knowledge File", text: $knowledge.file ?? "")
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
                                knowledgeViewModel.handleError(error: AppError.directoryNotReadable(path: directory.path()))
                            }
                            do {
                                knowledge.bookmark = try createBookmarkData(for: directory)
                                knowledge.knowledgeStatus = .ready
                            } catch {
                                knowledgeViewModel.handleError(error: error)
                            }
                            directory.stopAccessingSecurityScopedResource()
                        case .failure(let error):
                            knowledgeViewModel.handleError(error: error)
                        }
                    }
                }
                .padding(.top, 4)
                
                Picker("Chunk Size", selection: $knowledge.chunkSize) {
                    ForEach(chunkSizes, id: \.self) { chunkSize in
                        Text(String(chunkSize))
                            .tag(chunkSize)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.top, 4)
                
                LabeledContent {
                    HStack {
                        IntHideStepSlider(value: $knowledge.topK, range: 1...10, step: 1)
                        Text(String(knowledge.topK))
                    }
                } label: {
                    Text("Top K")
                }
                .padding(.top, 4)
                
                Picker("Embedding Model", selection: $knowledge.embedModel) {
                    ForEach(modelViewModel.models, id: \.self) { model in
                        Text(model.name)
                            .lineLimit(1)
                            .tag(model)
                    }
                }
                .padding(.top, 4)
                
                LabeledContent {
                    Text(knowledge.status)
                } label: {
                    Text("Status")
                }
                .padding(.top, 4)
                
                Button("Build Index") {
                    knowledgeViewModel.buildIndex(knowledge: knowledge)
                }
                .disabled(knowledge.knowledgeStatus == .inited)
                .buttonStyle(.borderedProminent)
                .rightAligned()
                .padding(.top, 4)
                
                Spacer()
                
            }
            .padding()
        }
    }

}
