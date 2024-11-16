//
//  TransformerRunner.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/11/14.
//

import Foundation
import Generation
import Tokenizers

actor TransformerRunner {
    func load(config: TransformerConfig, model: Mlmodel) async throws -> TFLanguageModel {
        var modelDirectory: URL?
        if let data = model.bookmark {
            modelDirectory = restoreFileAccess(with: data) { data in
                model.bookmark = data
            }
        }
        guard let directory = modelDirectory else {
            throw AppError.bizError(description: "The model path is invalid, please check it in settings.")
        }
        _ = directory.startAccessingSecurityScopedResource()
        defer {
            directory.stopAccessingSecurityScopedResource()
        }
        if !isDirectoryReadable(path: directory.path()) {
            throw AppError.directoryNotReadable(path: directory.path())
        }
        let languageModel = try TFLanguageModel.loadCompiled(url: directory, computeUnits: .all)
        return languageModel
    }
    
    func generate(prompt: String,
                  languageModel: TFLanguageModel,
                  generationConfig: GenerationConfig,
                  progressHandler: @escaping (String) -> Void) async throws -> String {
        return try await languageModel.generate(config: generationConfig, prompt: prompt) { inProgressGeneration in
            progressHandler(inProgressGeneration)
        }
    }
}
