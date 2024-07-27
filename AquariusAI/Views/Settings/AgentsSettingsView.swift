//
//  AgentSettingsView.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/4/26.
//

import SwiftData
import SwiftUI

struct AgentsSettingsView: View {
    
    @Environment(ErrorBinding.self) private var errorBinding
    @State private var showConfirmView = false
    @State private var agents: [Agent] = []
    @State private var selectedAgent: Agent?
    
    var body: some View {
        VStack {
            if agents.isEmpty {
                VStack {
                    Text("Please add some agents first.")
                        .padding(.top, 4)
                        .font(.title)
                    
                    Button("Add Agent") {
                        onAdd()
                    }
                }
                .frame(width: 840, height: 480)
            } else {
                HStack {
                    VStack(spacing: 0) {
                        List(selection: $selectedAgent) {
                            Section(header: Text("Models")) {
                                ForEach(agents) { agent in
                                    Label(agent.name, systemImage: "cube")
                                        .tag(agent)
                                }
                            }
                        }
                        
                        HStack {
                            Button("", systemImage: "plus") {
                                onAdd()
                            }
                            
                            Button("", systemImage: "minus") {
                                onConfirmDelete()
                            }
                            .alert(Text("Are you sure you want to delete the agent?"), isPresented: $showConfirmView) {
                                Button("Delete", role: .destructive) {
                                    onDelete()
                                }
                            }
                            
                            Spacer()
                        }
                        .buttonStyle(.accessoryBar)
                        .padding(8)
                        .background(Color.white)
                    }
                    .frame(width: 200, height: 480)
                    
                    if let agent = selectedAgent {
                        AgentsEditor(agent: agent)
                            .frame(width: 640, height: 480)
                    } else {
                        ContentUnavailableView {
                            Text("No Model Selected")
                        }
                        .frame(width: 640, height: 480)
                    }
                }
            }
        }
        .task {
            await onFetch()
        }
    }
    
    // MARK: - Actions
    private func onAdd() {
        let agent = Agent(name: "new agent")
        Task {
            await AgentService.shared.save(agent)
            await onFetch(selected: agent)
        }
    }
    
    private func onConfirmDelete() {
        if selectedAgent != nil {
            showConfirmView = true
        }
    }
    
    private func onDelete() {
        if let selectedAgent = selectedAgent {
            Task {
                await AgentService.shared.delete(selectedAgent)
                await onFetch()
            }
        }
    }
    
    private func onFetch(selected: Agent? = nil) async {
        do {
            agents = try await AgentService.shared.fetch()
            if selected != nil {
                selectedAgent = selected
            } else if !agents.isEmpty {
                selectedAgent = agents.first
            }
        } catch {
            errorBinding.appError = AppError.dbError(description: error.localizedDescription)
        }
    }

}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Agent.self, configurations: config)

    
    return AgentsSettingsView()
}
