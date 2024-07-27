//
//  AgentService.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/25.
//

import Foundation
import SwiftData

class AgentService: BaseService {
    
    static let shared = AgentService()
    
    private override init() {}
    
    func fetch() async throws -> [Agent] {
        let descriptor = FetchDescriptor<Agent>(
            sortBy: [SortDescriptor(\Agent.createdAt, order: .forward)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func save(_ agent: Agent) async {
        modelContext.insert(agent)
    }
    
    func delete(_ agent: Agent) async {
        modelContext.delete(agent)
    }
    
}
