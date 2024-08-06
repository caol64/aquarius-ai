//
//  IntHideStepSlider.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/6.
//

import SwiftUI

struct IntHideStepSlider: View {
    @Binding var value: Int
    var range: ClosedRange<Double>
    var step: Double
    
    var body: some View {
        HideStepSlider(value: Binding(get: {
            Double(value)
        }, set: { newValue in
            value = Int(newValue)
        }), range: range, step: step)
        
    }
}
