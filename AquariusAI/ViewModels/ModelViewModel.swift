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
        _fetch()
    }
    
    private func _fetch() {
        Task {
            let descriptor = FetchDescriptor<Models>(
                sortBy: [SortDescriptor(\Models.createdAt, order: .forward)]
            )
            models = _fetch(descriptor: descriptor)
        }
    }
    
    func fetch(modelFamily: ModelFamily) -> [Models] {
        return models.filter{ $0.family == modelFamily }
    }
    
    func fetch(modelType: ModelType) -> [Models] {
        return models.filter{ $0.type == modelType }
    }

    func get(id: String) -> Models? {
        return models.first(where: { $0.id == id })
    }
    
    func onAdd(modelType: ModelType) -> Models {
        let model = Models(name: "new model", family: modelType.supportedFamily.first!, type: modelType)
        save(model)
        _fetch()
        return model
    }
    
    func onDelete(model: Models?) {
        if let model = model {
            delete(model)
            _fetch()
        }
    }
    
    func selectDefault(modelFamily: ModelFamily) -> Models? {
        let models = fetch(modelFamily: modelFamily)
        return models.first
    }
    
    func selectDefault(modelType: ModelType) -> Models? {
        let models = fetch(modelType: modelType)
        return models.first
    }
    
    func handleModelPath(model: Models, directory: URL) {
        model.endpoint = directory.path()
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
