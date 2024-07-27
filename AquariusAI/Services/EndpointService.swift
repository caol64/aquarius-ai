//
//  EndpointService.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/23.
//

import Foundation
import SwiftData

class EndpointService: BaseService {
    
    static let shared = EndpointService()
    
    private override init() {}
    
    func fetch(modelFamily: ModelFamily) async throws -> [Endpoint] {
        let descriptor = FetchDescriptor<Endpoint>(
            predicate: #Predicate<Endpoint> { data in
                data.family == modelFamily.rawValue
            },
            sortBy: [SortDescriptor(\Endpoint.createdAt, order: .forward)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func save(_ endpoint: Endpoint) async {
        modelContext.insert(endpoint)
    }
    
    func delete(_ endpoint: Endpoint) async {
        modelContext.delete(endpoint)
    }
    
}
