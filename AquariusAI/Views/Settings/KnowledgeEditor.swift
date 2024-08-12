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
                            knowledgeViewModel.handleModelPath(knowledge: knowledge, directory: directory)
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
                    ForEach(modelViewModel.fetch(modelType: .embedding), id: \.self) { model in
                        Text(model.name)
                            .lineLimit(1)
                            .tag(Optional(model))
                    }
                }
                .padding(.top, 4)
                
                LabeledContent {
                    Text(knowledge.status.rawValue.capitalized)
                } label: {
                    Text("Status")
                }
                .padding(.top, 4)
                
                Button("Build Index") {
                    knowledgeViewModel.buildIndex(knowledge: knowledge)
                }
                .disabled(knowledge.status == .inited)
                .buttonStyle(.borderedProminent)
                .rightAligned()
                .padding(.top, 4)
                
                Spacer()
                
            }
            .padding()
        }
    }

}
