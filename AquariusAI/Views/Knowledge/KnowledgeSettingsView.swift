//
//  KnowledgeSettingsView.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/1.
//

import SwiftUI
import SwiftData

struct KnowledgeSettingsView: View {
    @Environment(KnowledgeViewModel.self) private var knowledgeViewModel
    @State private var showConfirmView = false
    @State private var selectedKnowledge: Knowledges?
    @State private var model: Models?
    
    var body: some View {
        VStack {
            if knowledgeViewModel.knowledges.isEmpty {
                emptyView
            } else {
                HStack {
                    sideBar
                        .frame(width: 240)
                    editor
                        .frame(width: 640)
                }
            }
        }
    }
    
    // MARK: - emptyView
    @ViewBuilder
    @MainActor
    private var emptyView: some View {
        Spacer()
        ContentUnavailableView {
            Label("Here is utterly empty.", systemImage: "tray.fill")
        } description: {
            Button("Add Knowledge") {
                onAdd()
            }
        }
        Spacer()
    }
    
    // MARK: - sideBar
    @MainActor
    private var sideBar: some View {
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
                    if selectedKnowledge != nil {
                        showConfirmView = true
                    }
                }
                .alert(Text("Are you sure you want to delete the knowledge?"), isPresented: $showConfirmView) {
                    Button("Delete", role: .destructive) {
                        if let knowledge = selectedKnowledge {
                            knowledgeViewModel.delete(knowledge)
                            selectedKnowledge = knowledgeViewModel.knowledges.first
                        }
                    }
                }
                
                Spacer()
            }
            .buttonStyle(.accessoryBar)
            .padding(8)
            .background(Color.white)
            
        }
    }
    
    // MARK: - editor
    @ViewBuilder
    private var editor: some View {
        if let knowledge = selectedKnowledge {
            KnowledgeEditor(knowledge: knowledge)
        } else {
            ContentUnavailableView {
                Text("No Knowledge Selected")
            }
        }
    }
    
    // MARK: - onAdd
    private func onAdd() {
        Task {
            let knowledge = Knowledges(name: "new knowledge")
            await knowledgeViewModel.save(knowledge)
            selectedKnowledge = knowledge
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Knowledges.self, configurations: config)
    container.mainContext.insert(Knowledges(name: "The Lord of the Rings"))
    container.mainContext.insert(Knowledges(name: "Linux Cookbook"))
    
    return KnowledgeSettingsView()
        .environment(KnowledgeViewModel(errorBinding: ErrorBinding(), modelContext: container.mainContext))
}
