//
//  KnowledgeSettingsView.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/1.
//

import SwiftUI
import SwiftData

struct KnowledgeSettingsView: View {
    @Environment(ErrorBinding.self) private var errorBinding
    @State private var showConfirmView = false
    @State private var selectedKnowledge: Knowledge?
    @State private var knowledgeViewModel = KnowledgeViewModel.shared
    @State private var endpoint: Endpoint?
    
    var body: some View {
        VStack {
            if knowledgeViewModel.knowledges.isEmpty {
                ContentUnavailableView {
                    Label("Here is utterly empty.", systemImage: "tray.fill")
                } description: {
                    Button("Add Knowledge") {
                        onAdd()
                    }
                }
            } else {
                HStack {
                    VStack(spacing: 0) {
                        List(selection: $selectedKnowledge) {
                            Section(header: Text("Knowledges")) {
                                ForEach(knowledgeViewModel.knowledges) { knowledge in
                                    Label(knowledge.name, systemImage: "cube")
                                        .tag(knowledge)
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
                            .alert(Text("Are you sure you want to delete the knowledge?"), isPresented: $showConfirmView) {
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
                    .frame(width: 240)
                    
                    VStack {
                        if let knowledge = selectedKnowledge {
                            KnowledgeEditor(knowledge: knowledge)
                        } else {
                            ContentUnavailableView {
                                Text("No Knowledge Selected")
                            }
                        }
                    }
                    .frame(width: 640)
                }
            }
        }
        .task {
            await knowledgeViewModel.fetch()
        }
    }
    
    // MARK: - Actions
    private func onAdd() {
        let knowledge = Knowledge(name: "new knowledge")
        Task {
            await knowledgeViewModel.save(knowledge)
            onChange(selected: knowledge)
        }
    }
    
    private func onConfirmDelete() {
        if selectedKnowledge != nil {
            showConfirmView = true
        }
    }
    
    private func onDelete() {
        if let knowledge = selectedKnowledge {
            Task {
                await knowledgeViewModel.delete(knowledge)
                onChange()
            }
        }
    }
    
    private func onChange(selected: Knowledge? = nil) {
        if selected != nil {
            selectedKnowledge = selected
        } else {
            let knowledges = knowledgeViewModel.knowledges
            if !knowledges.isEmpty {
                selectedKnowledge = knowledges.first
            }
        }
    }
    

}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Knowledge.self, configurations: config)
    container.mainContext.insert(Knowledge(name: "The Lord of the Rings"))
    container.mainContext.insert(Knowledge(name: "Linux Cookbook"))
    let errorBinding = ErrorBinding()
    KnowledgeViewModel.shared.configure(modelContext: container.mainContext, errorBinding: errorBinding)
    
    return KnowledgeSettingsView()
        .environment(errorBinding)
}
