//
//  ModelPickerToolbar.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/31.
//

import SwiftUI

struct ModelPickerToolbar: ToolbarContent {
    @Environment(ModelViewModel.self) private var modelViewModel
    @Binding var model: Models?
    @Binding var showModelPicker: Bool
    var title: String = "Aquarius AI"
    var modelType: ModelType
    
    @MainActor
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigation) {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .bold()
                HStack {
                    Text(model?.name ?? "")
                        .font(.subheadline)
                    Image(systemName: "chevron.down")
                        .resizable()
                        .frame(width: 10, height: 5)
                }
                .padding(.top, -4)
                .onTapGesture {
                    self.showModelPicker.toggle()
                }
            }
            .onAppear {
                model = modelViewModel.selectDefault(modelType: modelType)
            }
            .onChange(of: modelViewModel.models) {
                model = modelViewModel.selectDefault(modelType: modelType)
            }
        }
    }

}
