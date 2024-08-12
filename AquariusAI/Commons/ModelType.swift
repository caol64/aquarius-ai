//
//  ModelType.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/12.
//

import Foundation

enum ModelType: String, CaseIterable, Identifiable, Codable {
    case llm = "Large Language Model"
    case embedding = "Embedding Model"
    case diffusers = "Diffusers Model"
    case esrgan = "Esrgan Model"
    
    var id: Self { self }
}
