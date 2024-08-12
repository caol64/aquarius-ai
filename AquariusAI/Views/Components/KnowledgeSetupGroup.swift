//
//  KnowledgeSetupGroup.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/6.
//

import SwiftUI

struct KnowledgeSetupGroup: View {
    @Binding var expandId: String?
    @Binding var knowledge: Knowledges?
    @State private var showKnowledgeSheet = false
    
    var body: some View {
        Group {
            exclusiveExpandGroup(id: "knowledges", expandId: $expandId, noNeedExpand: knowledge == nil) {
                if let knowledge = knowledge {
                    HStack {
                        Text(knowledge.name)
                        Spacer()
                        Button {
                            
                        } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.leading, 16)
                    .padding(.trailing, 16)
                } else {
                    EmptyView()
                }
            } label: {
                HStack {
                    Text("Knowledges")
                    Spacer()
                    Button {
                        showKnowledgeSheet = true
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
                .buttonStyle(.plain)
                .sheet(isPresented: $showKnowledgeSheet) {
                    KnowledgePicker(knowledge: $knowledge)
                }
            }
        }
        
    }
}
