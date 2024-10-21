//
//  ModelFamily.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/5/6.
//

import Foundation

enum ModelFamily: String, CaseIterable, Identifiable, Codable {
    case coreml = "CoreML"
    case huggingface = "Hugging Face"
    case ollama = "Ollama"
    
    var id: Self { self }
    
}
