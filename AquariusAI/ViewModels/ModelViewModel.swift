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
    var models: [Mlmodel] = []
    
    override init(errorBinding: ErrorBinding, modelContext: ModelContext) {
        super.init(errorBinding: errorBinding, modelContext: modelContext)
        _fetch()
    }
    
    private func _fetch() {
        Task {
            let descriptor = FetchDescriptor<Mlmodel>(
                sortBy: [SortDescriptor(\Mlmodel.createdAt, order: .forward)]
            )
            models = _fetch(descriptor: descriptor)
        }
    }
    
    func fetch(modelType: ModelType) -> [Mlmodel] {
        return models.filter{ $0.type == modelType }
    }

    func get(id: String) -> Mlmodel? {
        return models.first(where: { $0.id == id })
    }
    
    func onAdd(modelType: ModelType) -> Mlmodel {
        let model = Mlmodel(name: "new model", type: modelType)
        save(model)
        _fetch()
        return model
    }
    
    func onDelete(model: Mlmodel?) {
        if let model = model {
            delete(model)
            _fetch()
        }
    }
    
    func selectDefault(modelFamily: ModelFamily) -> Mlmodel? {
        return models.first
    }
    
    func selectDefault(modelType: ModelType) -> Mlmodel? {
        let models = fetch(modelType: modelType)
        return models.first
    }
    
    func handleModelPath(model: Mlmodel, directory: URL) {
        model.name = directory.lastPathComponent
        let gotAccess = directory.startAccessingSecurityScopedResource()
        defer {
            directory.stopAccessingSecurityScopedResource()
        }
        if !gotAccess {
            handleError(error: AppError.directoryNotReadable(path: directory.path()))
        }
        do {
            model.bookmark = try createBookmarkData(for: directory)
        } catch {
            handleError(error: error)
        }
    }
    
}
