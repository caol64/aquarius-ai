//
//  IntHideStepSlider.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/6.
//

import SwiftUI

struct IntHideStepSlider: View {
    @Binding var value: Int
    var range: ClosedRange<Float>
    var step: Float
    
    var body: some View {
        HideStepSlider(value: Binding(get: {
            Float(value)
        }, set: { newValue in
            value = Int(newValue)
        }), range: range, step: step)
        
    }
}
