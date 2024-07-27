//
//  Agent.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/4/25.
//

import Foundation
import SwiftData

@Model
class Agent: Identifiable {
    @Attribute(.unique) var id: String = UUID().uuidString
    var name: String
    var systemPrompt: String = "You are Aquarius, a helpful assistant."
    var rawInstruct: Bool = false
    var createdAt: Date = Date.now
    var modifiedAt: Date = Date.now
    
    init(name: String) {
        self.name = name
    }
    
}
