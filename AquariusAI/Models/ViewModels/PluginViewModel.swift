//
//  PluginViewModel.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/4.
//

import Foundation
import SwiftData

@Observable
class PluginViewModel: BaseService {
    var plugins: [Plugin] = []
    static let shared = PluginViewModel()
    
    private override init() {}
    
    func get(family: PluginFamily) -> Plugin? {
        let descriptor = FetchDescriptor<Plugin>()
        do {
            let plugins = try modelContext.fetch(descriptor)
            if plugins.isEmpty {
                return nil
            } else {
                return plugins.filter {
                    $0.family == family
                }
                .first
            }
        } catch {
            errorBinding.appError = AppError.dbError(description: error.localizedDescription)
            return nil
        }
    }
    
    func getAndSave(family: PluginFamily) -> Plugin? {
        let plugin = get(family: family)
        if let plugin = plugin {
            return plugin
        } else {
            let plugin = Plugin(family: family)
            save(plugin)
            return plugin
        }
    }
    
    func save(_ plugin: Plugin) {
        modelContext.insert(plugin)
    }
    
}
