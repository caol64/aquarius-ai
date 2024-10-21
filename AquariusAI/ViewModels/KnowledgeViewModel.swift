//
//  KnowledgeViewModel.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/2.
//

import Foundation
import SwiftData

@Observable
class KnowledgeViewModel: BaseViewModel {
    let dataRepository: DataRepository
    var knowledges: [Knowledge] = []
    var isBuilding = false
    
    init(dataRepository: DataRepository) {
        self.dataRepository = dataRepository
        super.init()
        fetch()
    }
    
    private func fetch() {
        Task {
            let descriptor = FetchDescriptor<Knowledge>(
                sortBy: [SortDescriptor(\Knowledge.createdAt, order: .forward)]
            )
            knowledges = dataRepository.fetch(descriptor: descriptor) { error in
                handleError(error: error)
            }
        }
    }
    
    func onAdd() -> Knowledge {
        let knowledge = Knowledge(name: "new knowledge")
        dataRepository.save(knowledge)
        fetch()
        return knowledge
    }
    
    func onDelete(_ knowledge: Knowledge?) {
        if let knowledge = knowledge {
            dataRepository.delete(knowledge)
            fetch()
        }
    }
    
    func buildIndex(knowledge: Knowledge) {
        guard knowledge.status != .inited else {
            handleError(error: AppError.bizError(description: "Please choose the knowledge file."))
            return
        }
        guard let embedModel = knowledge.embedModel else {
            handleError(error: AppError.bizError(description: "Please setup an embedding model."))
            return
        }
        Task {
            isBuilding = true
            defer {
                isBuilding = false
            }
            do {
                try await knowledge.buildIndex(embedModel: embedModel)
                knowledge.status = .completed
            } catch {
                handleError(error: error)
            }
        }
    }
    
    func handleModelPath(knowledge: Knowledge, directory: URL) {
        knowledge.file = directory.path()
        knowledge.name = directory.lastPathComponent
        let gotAccess = directory.startAccessingSecurityScopedResource()
        defer {
            directory.stopAccessingSecurityScopedResource()
        }
        if !gotAccess {
            handleError(error: AppError.directoryNotReadable(path: directory.path()))
        }
        do {
            knowledge.bookmark = try createBookmarkData(for: directory)
            knowledge.status = .ready
        } catch {
            handleError(error: error)
        }
    }
    
}
