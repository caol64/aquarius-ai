//
//  EndpointPicker.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/25.
//

import SwiftUI

struct EndpointPicker: View {
    @Environment(ErrorBinding.self) private var errorBinding
    @Binding var endpoint: Endpoint?
    @State private var endpoints: [Endpoint] = []
    var modelFamily: ModelFamily
    
    var body: some View {
        Picker("Model", selection: $endpoint) {
            ForEach(endpoints) { endpoint in
                Text(endpoint.name)
                    .lineLimit(1)
                    .tag(Optional(endpoint))
            }
        }
        .task {
            await onFetch(modelFamily: modelFamily)
        }
    }
    
    
    private func onFetch(modelFamily: ModelFamily) async {
        do {
            endpoints = try await EndpointService.shared.fetch(modelFamily: modelFamily)
        } catch {
            errorBinding.appError = AppError.dbError(description: error.localizedDescription)
        }
        if endpoints.isEmpty {
            errorBinding.appError = AppError.noModel
            return
        }
        if endpoint == nil && !endpoints.isEmpty {
            endpoint = endpoints.first
        }
    }

}
