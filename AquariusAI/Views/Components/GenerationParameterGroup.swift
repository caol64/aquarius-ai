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
    @Binding var contextLength: Int
    @Binding var temperature: Float
    @Binding var seed: Int
    @Binding var repeatPenalty: Float
    @Binding var topP: Float
    
    var body: some View {
        Group {
            intSlideGroup(id: Groups.context.rawValue, expandId: $expandId, setting: $contextLength, range: 2048...131072, step: 1)
            slideGroup(id: Groups.temperature.rawValue, expandId: $expandId, setting: $temperature, range: 0...2, step: 0.1, precision: "%.1f")
            intSlideGroup(id: Groups.seed.rawValue, expandId: $expandId, setting: $seed, range: -1...65535, step: 1)
            slideGroup(id: Groups.repeatPenalty.rawValue, expandId: $expandId, setting: $repeatPenalty, range: 0...2, step: 0.1, precision: "%.1f")
            slideGroup(id: Groups.topP.rawValue, expandId: $expandId, setting: $topP, range: 0...1, step: 0.01, precision: "%.2f")
        }
    }

}
