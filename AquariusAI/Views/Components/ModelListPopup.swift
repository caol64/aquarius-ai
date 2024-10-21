//
//  ModelListPopup.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/8.
//

import SwiftUI

struct ModelListPopup: View {
    @Environment(ModelViewModel.self) private var modelViewModel
    @Binding var model: Mlmodel?
    @State private var menuWidth: CGFloat = 400
    @State private var menuHeight: CGFloat = 150
    var modelType: ModelType
    
    var body: some View {
        VStack {
            List(selection: $model) {
                Section(header: Text("Models")) {
                    ForEach(modelViewModel.fetch(modelType: modelType)) { model in
                        Label(model.name, systemImage: "cube")
                            .tag(model)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .frame(width: menuWidth, height: menuHeight)
            
            SettingsLink(
                label: {
                    Text("Manage Model")
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
            let height = CGFloat((models + 1) * 24 + 16)
            if height < menuHeight {
                menuHeight = height
            }
        }
    }
}

