//
//  ModelFamily.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/5/6.
//

import Foundation

enum ModelFamily: String, CaseIterable, Identifiable, Codable {
    case upscaler
    case ollama
    case openai
    case gemini
    case diffusers
    
    var id: Self { self }
    
    var host: String {
        switch self {
        case .upscaler: return "file://"
        case .ollama: return "http://127.0.0.1:11434"
        case .openai: return "https://openai.com"
        case .gemini: return "https://generativelanguage.googleapis.com"
        case .diffusers: return "folder://"
        }
    }
    
    var needAppKey: Bool {
        switch self {
        case .upscaler: return false
        case .ollama: return false
        case .openai: return true
        case .gemini: return true
        case .diffusers: return false
        }
    }
    
    var isLocal: Bool {
        return !self.host.starts(with: "http")
    }
    
    var isLocalFile: Bool {
        return self.host.starts(with: "file://")
    }
    
    var isLocalFolder: Bool {
        return self.host.starts(with: "folder://")
    }
    
}
