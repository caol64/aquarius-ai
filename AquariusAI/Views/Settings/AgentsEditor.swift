//
//  AgentsEditor.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/25.
//

import SwiftUI

struct AgentsEditor: View {
    @Environment(ErrorBinding.self) private var errorBinding
    @Bindable var agent: Agent
    
    var body: some View {
        VStack {
            Form {
                TextField("Agent Name", text: $agent.name)
                
                TextField("System Prompt", text: $agent.systemPrompt, axis: .vertical)
                    .lineLimit(7...7)
                    .padding(.top, 4)
                
                Toggle("Raw Instruct", isOn: $agent.rawInstruct)
                    .toggleStyle(.switch)
                    .padding(.top, 4)
            }
            .padding()
            
            Spacer()
        }
    }
}
