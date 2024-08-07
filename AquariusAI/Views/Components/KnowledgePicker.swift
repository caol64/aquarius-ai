//
//  KnowledgePicker.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/6.
//

import SwiftUI

struct KnowledgePicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var knowledge: Knowledge?
    @State private var knowledgeViewModel = KnowledgeViewModel.shared
    
    var body: some View {
        VStack {
            List(selection: $knowledge) {
                Section(header: Text("Knowledges")) {
                    ForEach(knowledgeViewModel.knowledges) { knowledge in
                        Label(knowledge.name, systemImage: "cube")
                            .tag(knowledge)
                    }
                }
            }
            Button("Cancel") {
                dismiss()
            }
        }
        .task {
            await onFetch()
        }
        .frame(width: 400, height: 400)
    }
    
    // MARK: - Actions
    private func onFetch() async {
        await knowledgeViewModel.fetch()
        print(knowledgeViewModel.knowledges)
    }
}
