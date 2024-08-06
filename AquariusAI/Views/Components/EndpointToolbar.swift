//
//  EndpointToolbar.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/31.
//

import SwiftUI

struct EndpointToolbar: ToolbarContent {
    @Environment(ErrorBinding.self) private var errorBinding
    @Binding var endpoint: Endpoint?
    @Binding var showEndpointPicker: Bool
    @State private var endpointViewModel = EndpointViewModel.shared
    var title: String = "Aquarius AI"
    var modelFamily: ModelFamily
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigation) {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .bold()
                HStack {
                    Text(endpoint?.name ?? "")
                        .font(.subheadline)
                    Image(systemName: "chevron.down")
                        .resizable()
                        .frame(width: 10, height: 5)
                }
                .padding(.top, -4)
                .onTapGesture {
                    self.showEndpointPicker.toggle()
                }
            }
            .onAppear {
                onFetch()
            }
            .onChange(of: endpointViewModel.endpoints) {
                onFetch()
            }
        }
    }
    
    // MARK: - Actions
    private func onFetch() {
        let endpoints = endpointViewModel.fetch(modelFamily: modelFamily)
        if !endpoints.isEmpty && endpoint == nil {
            endpoint = endpoints.first
        }
    }

}

struct EndpointsList: View {
    @Binding var endpoint: Endpoint?
    @State private var endpointViewModel = EndpointViewModel.shared
    @State private var menuWidth: CGFloat = 400
    @State private var menuHeight: CGFloat = 150
    var modelFamily: ModelFamily
    
    var body: some View {
        VStack {
            Text("Choose Model")
                .padding(.top, 8)
            List(endpointViewModel.fetch(modelFamily: modelFamily), selection: $endpoint) { endpoint in
                Text(endpoint.name)
                    .lineLimit(1)
                    .tag(endpoint)
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
        .onChange(of: endpointViewModel.endpoints) {
            caculateHeight()
        }
    }
    
    private func caculateHeight() {
        let endpoints = endpointViewModel.fetch(modelFamily: modelFamily).count
        let height = CGFloat((endpoints + 0) * 24)
        if height < menuHeight {
            menuHeight = height
        }
    }
    
}
