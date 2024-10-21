//
//  DataRepository.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/10/16.
//

import SwiftData

class DataRepository {
    let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetch<T: PersistentModel>(descriptor: FetchDescriptor<T>, onError: (_ error: Error) -> Void) -> [T] {
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            onError(error)
            return []
        }
    }
    
    func save<T: PersistentModel>(_ obj: T) {
        modelContext.insert(obj)
    }
    
    func delete<T: PersistentModel>(_ obj: T) {
        modelContext.delete(obj)
    }
}
