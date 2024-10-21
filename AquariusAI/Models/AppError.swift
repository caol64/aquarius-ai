//
//  AppError.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/5/12.
//

import Foundation

enum AppError: LocalizedError, Identifiable, Hashable {
    
    var id: Self { self }
    
    case bizError(description: String)
    case missingHost
    case missingPath
    case missingReferenceModel
    case missingModelName
    case missingModel
    case cantFindModel
    case missingAgentName
    case missingAgentModel
    case missingFilePath
    case directoryNotReadable(path: String)
    case promptEmpty
    case missingChat
    case noModel
    case modelNotLoaded
    // network error
    case networkError(description: String)
    // fatal error
    case dbError(description: String)
    case unexpected(description: String)
    
    var errorDescription: String? {
        switch self {
        case .bizError(let description):
            return description
        case .missingHost:
            return "Host may not be empty."
        case .missingPath:
            return "Model path may not be empty."
        case .missingReferenceModel:
            return "Reference model must be selected."
        case .missingModelName:
            return "Model name may not be empty."
        case .missingModel:
            return "Model must be selected."
        case .cantFindModel:
            return "Model name is invalid."
        case .missingAgentName:
            return "Agent name may not be empty."
        case .missingFilePath:
            return "Model file path may not be empty."
        case .missingAgentModel:
            return "Agent Model must be selected."
        case .directoryNotReadable(let path):
            return "Not have access to \(path)."
        case .promptEmpty:
            return "Prompt may not be empty."
        case .missingChat:
            return "Chat must be selected."
        case .noModel:
            return "Add some models first."
        case .modelNotLoaded:
            return "Failed to load model."
        case .networkError(let description):
            return "\(description)"
        case .dbError(let description):
            return "\(description)"
        case .unexpected(let description):
            return "\(description)"
        }
    }
    
}
