//
//  AgentPicker.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/25.
//

import SwiftUI

struct AgentPicker: View {
    @Environment(ErrorBinding.self) private var errorBinding
    @Binding var agent: Agent?
    @State private var agents: [Agent] = []
    
    var body: some View {
        Picker("Agent", selection: $agent) {
            ForEach(agents) { agent in
                Text(agent.name)
                    .lineLimit(1)
                    .tag(Optional(agent))
            }
        }
        .task {
            await onFetch()
        }
    }
    
    
    private func onFetch() async {
        do {
            agents = try await AgentService.shared.fetch()
        } catch {
            errorBinding.appError = AppError.dbError(description: error.localizedDescription)
        }
        if agent == nil && !agents.isEmpty {
            agent = agents.first
        }
    }
}
