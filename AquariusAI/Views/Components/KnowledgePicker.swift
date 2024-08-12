//
//  KnowledgePicker.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/6.
//

import SwiftUI

struct KnowledgePicker: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(KnowledgeViewModel.self) private var knowledgeViewModel
    @Binding var knowledge: Knowledges?
    
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
        .frame(width: 400, height: 200)
    }

}
