//
//  BaseViewModel.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/7.
//

import Foundation
import SwiftData

@MainActor
class BaseViewModel {
    let errorBinding: ErrorBinding
    let modelContext: ModelContext
    
    init(errorBinding: ErrorBinding, modelContext: ModelContext) {
        self.errorBinding = errorBinding
        self.modelContext = modelContext
    }
    
    func handleError(error: Error) {
        if let error = error as? AppError {
            errorBinding.appError = error
        } else {
            errorBinding.appError = AppError.unexpected(description: error.localizedDescription)
        }
    }
    
    func fetch<T: PersistentModel>(descriptor: FetchDescriptor<T>) -> [T] {
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            handleError(error: error)
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
