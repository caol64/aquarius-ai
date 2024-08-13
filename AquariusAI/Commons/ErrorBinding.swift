//
//  ErrorBinding.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/23.
//

import SwiftUI

@Observable
class ErrorBinding {
    var appError: AppError?
    
    var showError: Binding<Bool> {
        Binding {
            return self.appError != nil
        } set: { showError in
            if !showError {
                self.appError = nil
            }
        }
    }
}
