//
//  ModelListPopup.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/8.
//

import SwiftUI

struct ModelListPopup: View {
    @Environment(ModelViewModel.self) private var modelViewModel
    @Binding var model: Models?
    @State private var menuWidth: CGFloat = 400
    @State private var menuHeight: CGFloat = 150
    var modelType: ModelType
    
    var body: some View {
        VStack {
            Text("Choose Model")
                .padding(.top, 8)
            List(modelViewModel.fetch(modelType: modelType), selection: $model) { model in
                Text(model.name)
                    .lineLimit(1)
                    .tag(model)
            }
            .listStyle(PlainListStyle())
            .frame(width: menuWidth, height: menuHeight)
            
            Divider()
            SettingsLink(
                label: {
                    Text("Manage Models")
                }
            )
            .padding(.bottom, 8)
        }
        .frame(width: menuWidth, height: menuHeight + 80)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(radius: 5)
        )
        .leftAligned()
        .padding(8)
        .onAppear() {
            caculateHeight()
        }
        .onChange(of: modelViewModel.models) {
            caculateHeight()
        }
    }
    
    private func caculateHeight() {
        Task {
            let models = await modelViewModel.fetch(modelType: modelType).count
            let height = CGFloat((models + 0) * 24)
            if height < menuHeight {
                menuHeight = height
            }
        }
    }
}

