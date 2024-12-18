//
//  HideStepSlider.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/6.
//

import SwiftUI

struct HideStepSlider: View {
    @Binding var value: Float
    var range: ClosedRange<Float>
    var step: Float
    
    var body: some View {
        Slider(value: Binding(
            get: {
                value
            },
            set: { newValue in
                let remainder = newValue.truncatingRemainder(dividingBy: step)
                if remainder != 0 {
                    let base = newValue - remainder
                    value = base + step
                } else {
                    value = newValue
                }
            }
        ), in: range)
    }
}
