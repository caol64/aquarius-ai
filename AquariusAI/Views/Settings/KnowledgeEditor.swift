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
                
                LabeledContent("Top K") {
                    HStack {
                        IntHideStepSlider(value: $knowledge.topK, range: 1...10, step: 1)
                        Text(String(knowledge.topK))
                    }
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
                
                LabeledContent("Status") {
                    if knowledge.status == .completed {
                        Text("Indexing is complete.")
                            .foregroundColor(.green)
                    } else {
                        Text("Indexing is not yet complete.")
                            .foregroundColor(.red)
                    }
                }
                .padding(.top, 4)
                
                if knowledge.status != .inited && knowledge.embedModel != nil {
                    ZStack {
                        Button("Build Index") {
                            knowledgeViewModel.buildIndex(knowledge: knowledge)
                        }
                        .disabled(knowledgeViewModel.isBuilding)
                        
                        if knowledgeViewModel.isBuilding {
                            ProgressView()
                                .scaleEffect(0.5)
                                .frame(width: 10, height: 10)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .rightAligned()
                    .padding(.top, 4)
                }
                
                Spacer()
                
            }
            .padding()
        }
    }

}
