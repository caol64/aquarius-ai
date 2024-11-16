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
    private let dataRepository: DataRepository
    private let descriptor = FetchDescriptor<Mlmodel>(
        sortBy: [SortDescriptor(\Mlmodel.createdAt, order: .forward)]
    )
    var models: [Mlmodel] = []
    
    init(dataRepository: DataRepository) {
        self.dataRepository = dataRepository
        super.init()
        _fetch()
    }
    
    private func _fetch() {
        models = dataRepository.fetch(descriptor: descriptor) { error in
            handleError(error: error)
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
        dataRepository.save(model)
        _fetch()
        return model
    }
    
    func onDelete(model: Mlmodel?) {
        if let model = model {
            dataRepository.delete(model)
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
        model.localPath = directory.path()
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
