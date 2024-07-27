//
//  ErrorBinding.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/23.
//

import Foundation
import SwiftUI

@Observable
class ErrorBinding {
    // TODO window group bug
    var appError: AppError?
    
    var showError: Binding<Bool> {
        Binding {
            return self.appError != nil
        } set: {
            if !$0 {
                self.appError = nil
            }
        }
    }
}
