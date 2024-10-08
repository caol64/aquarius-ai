//
//  ModelFamily.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/5/6.
//

import Foundation

enum ModelFamily: String, CaseIterable, Identifiable, Codable {
    case ollama = "Ollama"
    case gpt = "GPT"
    case gemini = "Gemini"
    case mlmodel = "MLModel"
    
    var id: Self { self }
    
    var host: String {
        switch self {
        case .ollama: return "http://127.0.0.1:11434"
        case .gpt: return "https://openai.com"
        case .gemini: return "https://generativelanguage.googleapis.com"
        case .mlmodel: return "file://"
        }
    }
    
    var needAppKey: Bool {
        switch self {
        case .ollama: return false
        case .gpt: return true
        case .gemini: return true
        case .mlmodel: return false
        }
    }
    
    var isLocal: Bool {
        return !self.host.starts(with: "http")
    }
    
}
