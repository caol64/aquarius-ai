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
        case topK = "Top K"
        case topP = "Top P"
    }
    
    @State private var expandedGroup: Groups?
    @Binding var config: OllamaConfig
    
    var body: some View {
        Group {
            intSettingGroup(group: .context, setting: $config.contextLength)
            doubleSlideGroup(group: .temperature, setting: $config.temperature, range: 0...2, step: 0.1, precision: "%.1f")
            intSettingGroup(group: .seed, setting: $config.seed)
            doubleSettingGroup(group: .repeatPenalty, setting: $config.repeatPenalty)
//            intSettingGroup(group: .topK, setting: $config.topK)
            doubleSlideGroup(group: .topP, setting: $config.topP, range: 0...1, step: 0.01, precision: "%.2f")
        }
    }
    
    private func doubleSlideGroup(group: Groups, setting: Binding<Double>, range: ClosedRange<Double>, step: Double, precision: String) -> some View {
        disclosureGroup(group: group, view: AnyView(
            HideStepSlider(value: setting, range: range, step: step)
        ), label: AnyView(
            HStack {
                Text(group.rawValue)
                Spacer()
                Text(String(String(format: precision, setting.wrappedValue)))
                Button {
                    
                } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.plain)
            }
        ))
    }
    
    private func intSettingGroup(group: Groups, setting: Binding<Int>) -> some View {
        disclosureGroup(group: group, view: AnyView(
            TextField("", value: setting, format: .number)
                .padding(.leading, 16)
        ), label: AnyView(
            HStack {
                Text(group.rawValue)
                Spacer()
                Text(String(setting.wrappedValue))
                Button {
                    
                } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.plain)
            }
        ))
    }

    private func doubleSettingGroup(group: Groups, setting: Binding<Double>) -> some View {
        disclosureGroup(group: group, view: AnyView(
            TextField("", value: setting, format: .number)
                .padding(.leading, 16)
        ), label: AnyView(
            HStack {
                Text(group.rawValue)
                Spacer()
                Text(String(setting.wrappedValue))
                Button {
                    
                } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.plain)
            }
        ))
    }

    private func disclosureGroup(group: Groups, view: any View, label: any View) -> some View {
        DisclosureGroup(isExpanded: Binding(
            get: { expandedGroup == group },
            set: { newValue in
                expandedGroup = newValue ? group : nil
            }
        )) {
            AnyView(view)
        } label: {
            AnyView(label)
        }
    }

}

// MARK: - Preview
#Preview {
    @State var config: OllamaConfig = OllamaConfig()
    return GenerationParameterGroup(config: $config)
}
