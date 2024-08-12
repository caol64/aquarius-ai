//
//  GenerationParameterGroup.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/1.
//

import SwiftUI

struct GenerationParameterGroup: View {
    enum Groups: String {
        case context = "Context Length"
        case temperature = "Temperature"
        case seed = "Seed"
        case repeatPenalty = "Repeat Penalty"
        case topP = "Top P"
    }
    
    @Binding var expandId: String?
    @Binding var config: LlmConfig
    
    var body: some View {
        Group {
            intSlideGroup(id: Groups.context.rawValue, expandId: $expandId, setting: $config.contextLength, range: 2048...8192, step: 1)
            doubleSlideGroup(id: Groups.temperature.rawValue, expandId: $expandId, setting: $config.temperature, range: 0...2, step: 0.1, precision: "%.1f")
            intSlideGroup(id: Groups.seed.rawValue, expandId: $expandId, setting: $config.seed, range: -1...65535, step: 1)
            doubleSlideGroup(id: Groups.repeatPenalty.rawValue, expandId: $expandId, setting: $config.repeatPenalty, range: 0...2, step: 0.1, precision: "%.1f")
            doubleSlideGroup(id: Groups.topP.rawValue, expandId: $expandId, setting: $config.topP, range: 0...1, step: 0.01, precision: "%.2f")
        }
    }

}

// MARK: - Preview
#Preview {
    @State var config: LlmConfig = LlmConfig()
    @State var expandId: String?
    return GenerationParameterGroup(expandId: $expandId, config: $config)
}
