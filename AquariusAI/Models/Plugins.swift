//
//  Plugins.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/4.
//

import Foundation
import SwiftData

@Model
class Plugins: Identifiable {
    @Attribute(.unique) var id: String = UUID().uuidString
    var family: String
    var modelId: String?
    var modelName: String?
    var createdAt: Date = Date.now
    var modifiedAt: Date = Date.now
    
    init(pluginFamily: PluginFamily) {
        self.family = pluginFamily.rawValue
    }
    
    var pluginFamily: PluginFamily {
        get {
            return PluginFamily(rawValue: family)!
        }
        set {
            family = newValue.rawValue
        }
    }
}
