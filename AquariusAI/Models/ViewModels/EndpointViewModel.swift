//
//  EndpointViewModel.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/23.
//

import Foundation
import SwiftData

@Observable
class EndpointViewModel: BaseService {
    var endpoints: [Endpoint] = []
    static let shared = EndpointViewModel()
    
    private override init() {}
    
    func fetch() async {
        let descriptor = FetchDescriptor<Endpoint>(
            sortBy: [SortDescriptor(\Endpoint.createdAt, order: .forward)]
        )
        do {
            endpoints = try modelContext.fetch(descriptor)
        } catch {
            errorBinding.appError = AppError.dbError(description: error.localizedDescription)
        }
    }
    
    func fetch(modelFamily: ModelFamily) -> [Endpoint] {
        return endpoints.filter{ $0.modelFamily == modelFamily }
    }
    
    func save(_ endpoint: Endpoint) async {
        modelContext.insert(endpoint)
        await fetch()
    }
    
    func delete(_ endpoint: Endpoint) async {
        modelContext.delete(endpoint)
        await fetch()
    }
    
    func get(id: String) -> Endpoint? {
        return endpoints.first(where: { $0.id == id })
    }
    
}
