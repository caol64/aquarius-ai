//
//  BaseViewModel.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/7.
//

import Foundation
import SwiftData

class BaseViewModel {
    
    func handleError(error: Error) {
        if let error = error as? AppError {
            AppState.appError = error
        } else {
            AppState.appError = AppError.unexpected(description: error.localizedDescription)
        }
    }
    
}
