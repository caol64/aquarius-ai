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
    @Bindable var model: Mlmodel
    
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
                
                HStack(alignment: .bottom) {
                    TextField("Local Path", text: $model.localPath)
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
                
                Spacer()
                
            }
            .padding()
        }
    }
    
}
