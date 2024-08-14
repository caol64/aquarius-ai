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
    var errorBinding: ErrorBinding = ErrorBinding()
    var openedWindows: Set<Page> = []
    
    func activePage(page: Page) {
        self.activatedPage = page
    }

    var showSettingsError: Binding<Bool> {
        Binding {
            return self.errorBinding.appError != nil && self.activatedPage == .settings
        } set: { showError in
            if !showError {
                self.errorBinding.appError = nil
            }
        }
    }
    
    var showTextError: Binding<Bool> {
        Binding {
            return self.errorBinding.appError != nil && self.activatedPage == .text
        } set: { showError in
            if !showError {
                self.errorBinding.appError = nil
            }
        }
    }
    
    var showImageError: Binding<Bool> {
        Binding {
            return self.errorBinding.appError != nil && self.activatedPage == .image
        } set: { showError in
            if !showError {
                self.errorBinding.appError = nil
            }
        }
    }
}
