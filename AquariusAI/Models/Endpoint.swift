//
//  Endpoint.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/23.
//

import Foundation
import SwiftData

@Model
class Endpoint: Identifiable {
    @Attribute(.unique) var id: String = UUID().uuidString
    var name: String
    var family: String
    var host: String = ""
    var endpoint: String = ""
    var appkey: String = ""
    var createdAt: Date = Date.now
    var modifiedAt: Date = Date.now
    var bookmark: Data?
    
    init(name: String, modelFamily: ModelFamily) {
        self.name = name
        self.family = modelFamily.rawValue
        self.host = modelFamily.host
    }
    
    var modelFamily: ModelFamily {
        get {
            return ModelFamily(rawValue: family)!
        }
        set {
            family = newValue.rawValue
        }
    }
}
