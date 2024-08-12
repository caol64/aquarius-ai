//
//  Agent.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/9.
//

import Foundation

class Agent {
    private var models: [Models] = []
    private var knowledges: [Knowledges] = []
    
    init(model: Models, knowledge: Knowledges? = nil) {
        self.models.append(model)
        knowledge.map { self.knowledges.append($0) }
    }

}
