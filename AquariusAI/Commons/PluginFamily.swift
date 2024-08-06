//
//  PluginFamily.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/4.
//

import Foundation

enum PluginFamily: String, Identifiable, CaseIterable {
    case webSearch = "Web Search"
    case embedding = "Embedding"
    case upscaler = "Upscaler"
    
    var id: Self { self }
}
