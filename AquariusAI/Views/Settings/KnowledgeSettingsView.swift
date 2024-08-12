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
    @State private var pageState: SettingsPageState<Knowledges> = .empty
    
    var body: some View {
        VStack {
            switch pageState {
            case .empty:
                Spacer()
                ContentUnavailableView {
                    Label("Here is utterly empty.", systemImage: "tray.fill")
                } description: {
                    Button("Add Knowledge") {
                        selectedKnowledge = knowledgeViewModel.onAdd()
                    }
                }
                Spacer()
            case .noItemSelected:
                HStack {
                    sideBar
                        .frame(width: 240)
                    ContentUnavailableView {
                        Text("No Knowledge Selected")
                    }
                    .frame(width: 640)
                }
            case .itemSelected(let knowledge):
                HStack {
                    sideBar
                        .frame(width: 240)
                    KnowledgeEditor(knowledge: knowledge)
                        .frame(width: 640)
                }
            }
        }
        .onAppear {
            updatePageState()
        }
        .onChange(of: selectedKnowledge) {
            updatePageState()
        }
        .onChange(of: knowledgeViewModel.knowledges) {
            updatePageState()
        }
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
                    selectedKnowledge = knowledgeViewModel.onAdd()
                }
                
                Button("", systemImage: "minus") {
                    if selectedKnowledge != nil {
                        showConfirmView = true
                    }
                }
                .alert(Text("Are you sure you want to delete the knowledge?"), isPresented: $showConfirmView) {
                    Button("Delete", role: .destructive) {
                        knowledgeViewModel.onDelete(selectedKnowledge)
                    }
                }
                
                Spacer()
            }
            .buttonStyle(.accessoryBar)
            .padding(8)
            .background(Color.white)
        }
    }
    
    // MARK: - updatePageState
    @MainActor
    private func updatePageState() {
        if knowledgeViewModel.knowledges.isEmpty {
            pageState = .empty
        } else if selectedKnowledge == nil {
            pageState = .noItemSelected
        } else if let knowledge = selectedKnowledge {
            pageState = .itemSelected(knowledge)
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
