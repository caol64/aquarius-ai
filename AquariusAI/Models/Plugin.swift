//
//  Plugin.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/4.
//

import Foundation
import SwiftData

@Model
class Plugin: Identifiable {
    @Attribute(.unique) var id: String = UUID().uuidString
    var _family: String
    var endpointId: String?
    var createdAt: Date = Date.now
    var modifiedAt: Date = Date.now
    
    init(family: PluginFamily) {
        self._family = family.rawValue
    }
    
    var family: PluginFamily {
        get {
            return PluginFamily(rawValue: _family)!
        }
        set {
            _family = newValue.rawValue
        }
    }
}
