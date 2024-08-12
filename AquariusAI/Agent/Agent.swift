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
    private var plugins: [Plugins] = []
    
    init(model: Models, knowledge: Knowledges? = nil, plugin: Plugins? = nil) {
        self.models.append(model)
        knowledge.map { self.knowledges.append($0) }
        plugin.map { self.plugins.append($0) }
    }

}
