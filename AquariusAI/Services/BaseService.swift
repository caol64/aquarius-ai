//
//  BaseService.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/25.
//

import SwiftData

class BaseService {
    private(set) var _modelContext: ModelContext?
    private(set) var _errorBinding: ErrorBinding?

    func configure(modelContext: ModelContext, errorBinding: ErrorBinding) {
        self._modelContext = modelContext
        self._errorBinding = errorBinding
    }
    
    var modelContext: ModelContext {
        return _modelContext!
    }
    
    var errorBinding: ErrorBinding {
        return _errorBinding!
    }
}
