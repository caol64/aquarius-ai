//
//  ModelViewModel.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/23.
//

import Foundation
import SwiftData

@Observable
class ModelViewModel: BaseViewModel {
    var models: [Models] = []
    
    override init(errorBinding: ErrorBinding, modelContext: ModelContext) {
        super.init(errorBinding: errorBinding, modelContext: modelContext)
        fetch()
    }
    
    private func fetch() {
        Task {
            let descriptor = FetchDescriptor<Models>(
                sortBy: [SortDescriptor(\Models.createdAt, order: .forward)]
            )
            models = fetch(descriptor: descriptor)
        }
    }
    
    func fetch(modelFamily: ModelFamily) -> [Models] {
        return models.filter{ $0.modelFamily == modelFamily }
    }

    func get(id: String) -> Models? {
        return models.first(where: { $0.id == id })
    }
    
    func onAdd(_ model: Models) {
        save(model)
        fetch()
    }
    
    func onDelete(_ model: Models) {
        delete(model)
        fetch()
    }
    
    func selectDefault(modelFamily: ModelFamily) -> Models? {
        let models = fetch(modelFamily: modelFamily)
        return models.first
    }
    
}
