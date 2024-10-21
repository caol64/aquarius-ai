//
//  ModelFamily.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/5/6.
//

import Foundation

enum ModelFamily: String, CaseIterable, Identifiable, Codable {
    case transformer = "transformer"
    case stableDiffusion = "stable diffusion"
    
    var id: Self { self }
    
}
