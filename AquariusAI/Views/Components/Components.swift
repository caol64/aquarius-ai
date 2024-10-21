//
//  Components.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/25.
//

import SwiftUI

func generationOptions() -> some View {
    Label("Genaration Options", systemImage: "gearshape.2.fill")
        .font(.system(size: 12, weight: .bold, design: .default))
        .leftAligned()
}

func exclusiveExpandGroup<T: Equatable>(id: T,
                                        expandId: Binding<T?>,
                                        noNeedExpand: Bool = false,
                                        @ViewBuilder view: @escaping () -> some View,
                                        @ViewBuilder label: () -> some View) -> some View {
    return DisclosureGroup(isExpanded: Binding(
        get: { id == expandId.wrappedValue },
        set: { isExpanded in
            expandId.wrappedValue = noNeedExpand ? nil : isExpanded ? id : nil
        }
    )) {
        view()
    } label: {
        label()
    }
}

func slideGroup(id: String, expandId: Binding<String?>, setting: Binding<Float>, range: ClosedRange<Float>, step: Float, precision: String) -> some View {
    exclusiveExpandGroup(id: id, expandId: expandId) {
        HideStepSlider(value: setting, range: range, step: step)
    } label: {
        HStack {
            Text(id)
            Spacer()
            Text(String(String(format: precision, setting.wrappedValue)))
            Button {
                
            } label: {
                Image(systemName: "info.circle")
            }
            .buttonStyle(.plain)
        }
    }
}

func intSlideGroup(id: String, expandId: Binding<String?>, setting: Binding<Int>, range: ClosedRange<Float>, step: Float) -> some View {
    exclusiveExpandGroup(id: id, expandId: expandId) {
        IntHideStepSlider(value: setting, range: range, step: step)
    } label: {
        HStack {
            Text(id)
            Spacer()
            Text(String(setting.wrappedValue))
            Button {
                
            } label: {
                Image(systemName: "info.circle")
            }
            .buttonStyle(.plain)
        }
    }
}
