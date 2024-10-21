//
//  SettingsPageState.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/12.
//

import Foundation

enum SettingsPageState<T> {
    case empty
    case noItemSelected
    case itemSelected(T)
}
