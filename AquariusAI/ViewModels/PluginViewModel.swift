//
//  PluginViewModel.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/4.
//

import Foundation
import SwiftData

@Observable
class PluginViewModel: BaseViewModel {
    var plugins: [Plugins] = []
    
    override init(errorBinding: ErrorBinding, modelContext: ModelContext) {
        super.init(errorBinding: errorBinding, modelContext: modelContext)
        fetch()
    }
    
    private func fetch() {
        Task {
            let descriptor = FetchDescriptor<Plugins>(
                sortBy: [SortDescriptor(\Plugins.createdAt, order: .forward)]
            )
            plugins = fetch(descriptor: descriptor)
        }
    }
    
    func fetch(family: PluginFamily) -> [Plugins] {
        return plugins.filter { $0.family == family.rawValue }
    }
    
    func get(family: PluginFamily) -> Plugins? {
        return plugins.first(where: { $0.family == family.rawValue })
    }
    
    func getAndSave(family: PluginFamily) -> Plugins? {
        if let plugin = get(family: family) {
            return plugin
        } else {
            let plugin = Plugins(pluginFamily: family)
            save(plugin)
            return plugin
        }
    }
    
}
