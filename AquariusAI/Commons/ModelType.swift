//
//  ModelType.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/12.
//

import Foundation

enum ModelType: String, CaseIterable, Identifiable, Codable {
    case llm = "Language Model"
    case embedding = "Embedding Model"
    case diffusers = "Diffusers Model"
    case esrgan = "Esrgan Model"
    
    var id: Self { self }
    
    var supportedFamily: [ModelFamily] {
        switch self {
        case .llm:
            return [.ollama, .gpt, .gemini]
        case .embedding:
            return [.ollama, .gpt, .gemini]
        case .diffusers:
            return [.mlmodel]
        case .esrgan:
            return [.mlmodel]
        }
    }
}
