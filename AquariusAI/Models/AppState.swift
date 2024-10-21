//
//  AppState.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/9.
//

import Foundation
import SwiftUI

@Observable
class AppState {
    var activatedPage: Page?
    static var appError: AppError?
    
    var showError: Binding<Bool> {
        Binding {
            return AppState.appError != nil
        } set: { showError in
            if !showError {
                AppState.appError = nil
            }
        }
    }
    var openedWindows: Set<Page> = []
    
    func activePage(page: Page) {
        self.activatedPage = page
    }

    var showSettingsError: Binding<Bool> {
        Binding {
            return AppState.appError != nil && self.activatedPage == .settings
        } set: { showError in
            if !showError {
                AppState.appError = nil
            }
        }
    }
    
    var showTextError: Binding<Bool> {
        Binding {
            return AppState.appError != nil && self.activatedPage == .text
        } set: { showError in
            if !showError {
                AppState.appError = nil
            }
        }
    }
    
    var showImageError: Binding<Bool> {
        Binding {
            return AppState.appError != nil && self.activatedPage == .image
        } set: { showError in
            if !showError {
                AppState.appError = nil
            }
        }
    }
    
    var error: AppError? {
        return AppState.appError
    }
}
