//
//  BaseService.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/25.
//

import Foundation
import SwiftData

class BaseService {
    private(set) var _modelContext: ModelContext?

    func configure(with modelContext: ModelContext) {
        self._modelContext = modelContext
    }
    
    var modelContext: ModelContext {
        return _modelContext!
    }
    
}
