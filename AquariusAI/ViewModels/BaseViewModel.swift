//
//  BaseViewModel.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/7.
//

import Foundation
import SwiftData

class BaseViewModel {
    let appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    func handleError(error: Error) {
        if let error = error as? AppError {
            appState.appError = error
        } else {
            appState.appError = AppError.unexpected(description: error.localizedDescription)
        }
    }
    
}
