//
//  ModelFamily.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/5/6.
//

import Foundation

enum ModelFamily: String, CaseIterable, Identifiable, Codable {
    case llamacpp
    case ollama
    case openai
    case gemini
    case sd
    
    var id: Self { self }
    
    var host: String {
        switch self {
        case .llamacpp: return "file://"
        case .ollama: return "http://127.0.0.1:11434"
        case .openai: return "https://openai.com"
        case .gemini: return "https://generativelanguage.googleapis.com"
        case .sd: return "file://"
        }
    }
    
    var needAppKey: Bool {
        switch self {
        case .llamacpp: return false
        case .ollama: return false
        case .openai: return true
        case .gemini: return true
        case .sd: return false
        }
    }
    
    var isLocalFile: Bool {
        return self.host.starts(with: "file://")
    }
    
}
