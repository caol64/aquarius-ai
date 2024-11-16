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
    private var activatedPage: Page?
    static var appError: AppError?
    
    @ObservationIgnored
    var openedWindows: Set<Page> = []
    
    func activePage(page: Page) {
        self.activatedPage = page
    }

    @MainActor
    var showSettingsError: Binding<Bool> {
        Binding {
            return AppState.appError != nil && self.activatedPage == .settings
        } set: { showError in
            if !showError && self.activatedPage == .settings {
                AppState.appError = nil
            }
        }
    }
    
    @MainActor
    var showTextError: Binding<Bool> {
        Binding {
            return AppState.appError != nil && self.activatedPage == .text
        } set: { showError in
            if !showError && self.activatedPage == .text {
                AppState.appError = nil
            }
        }
    }
    
    @MainActor
    var showImageError: Binding<Bool> {
        Binding {
            return AppState.appError != nil && self.activatedPage == .image
        } set: { showError in
            if !showError && self.activatedPage == .image {
                AppState.appError = nil
            }
        }
    }
    
    @ObservationIgnored
    var error: AppError? {
        return AppState.appError
    }
}
