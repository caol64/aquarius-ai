//
//  ImageGenerateView.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/1.
//

import SwiftUI
import SwiftData

struct ImageGenerateView: View {
    
    enum GenerationState {
        case startup
        case running
        case complete(CGImage?)
        //        case userCanceled
        case failed
    }
    
    @Environment(ErrorBinding.self) private var errorBinding
    @State private var prompt: String = ""
    @State private var negativePrompt: String = ""
    @State private var modelName: String = ""
    @State private var endpoint: Endpoint?
    @State private var showFileExporter: Bool = false
    @State private var config: DiffusersConfig = DiffusersConfig()
    @State private var generationState: GenerationState = .startup
    
    var body: some View {
        NavigationSplitView {
            VStack() {
                genrateOptions()
                prompts()
                ModelPicker(endpoint: $endpoint, modelFamily: .sd)
                    .padding(.top, 4)
                    .onChange(of: endpoint) {
                        onModelChange(endpoint: endpoint)
                    }
                generationConfigs(config: $config)
                generationButton()
                    .padding(.top, 4)
            }
            .topAligned()
            .padding()
            .navigationSplitViewColumnWidth(300)
        } detail: {
            VStack {
                switch generationState {
                case .startup, .failed:
                    Image(systemName: "photo")
                case .running:
                    ProgressView()
                case .complete(let image):
                    completeView(image: image)
                }
            }
            .navigationTitle("Stable Diffusion")
            .navigationSubtitle(modelName)
            .navigationSplitViewColumnWidth(min: 600, ideal: 600, max: 900)
        }
        .onDisappear {
            DiffusersPipeline.clear()
        }
        
    }
    
    private func prompts() -> some View {
        VStack {
            Text("Prompts")
                .padding(.top, 4)
                .leftAligned()
            TextField("Prompt", text: $prompt, axis: .vertical)
                .lineLimit(7...7)
            TextField("Negative Prompt", text: $negativePrompt, axis: .vertical)
                .lineLimit(3...3)
        }
    }
    
    private func generationConfigs(config: Binding<DiffusersConfig>) -> some View {
        VStack {
            HStack {
                Slider(value: Binding(
                    get: {
                        Float(config.wrappedValue.stepCount)
                    },
                    set: { newValue in
                        config.wrappedValue.stepCount = Int(newValue)
                    }
                ), in: 1...50, step: 1) {
                    Text("Steps")
                }
                Text(String(config.wrappedValue.stepCount))
            }
            .padding(.top, 4)
            
            HStack {
                Slider(value: $config.cfgScale, in: 1...30, step: 0.5) {
                    Text("CFG Scale")
                }
                Text(String(format: "%.1f", config.wrappedValue.cfgScale))
            }
            .padding(.top, 4)
            
            Toggle(isOn: $config.isXL) {
                Text("XL")
            }
            .leftAligned()
            .padding(.top, 4)
        }
    }
    
    private func generationButton() -> some View {
        Button("Generate") {
            onGenerate()
        }
        .buttonStyle(.borderedProminent)
        .rightAligned()
    }
    
    private func completeView(image: CGImage?) -> some View {
        VStack {
            Image(image!, scale: 1.0, label: Text(""))
                .resizable()
                .scaledToFit()
        }
        .aspectRatio(contentMode: .fit)
        .frame(width: 512, height: 512)
        .cornerRadius(15)
        .toolbar {
            Button("Save", systemImage: "square.and.arrow.down") {
                showFileExporter = true
            }
            .fileExporter(
                isPresented: $showFileExporter,
                document: createDocument(image: image),
                contentType: .png,
                defaultFilename: "out"
            ) { result in
                switch result {
                case .success(let url):
                    print("File saved to \(url)")
                case .failure(let error):
                    print("Failed to save file: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Actions
    private func onGenerate() {
        if case .running = generationState {
            return
        }
        if prompt.isEmpty {
            errorBinding.appError = AppError.promptEmpty
        }
        guard let endpoint = endpoint else {
            errorBinding.appError = AppError.missingModel
            return
        }
        Task {
            generationState = .running
            do {
                if DiffusersPipeline.shared == nil {
                    try await DiffusersPipeline.load(endpoint: endpoint, diffusersConfig: config)
                }
                guard let pipeline = DiffusersPipeline.shared else {
                    return
                }
                try await pipeline.generate(prompt: prompt, negativePrompt: negativePrompt, diffusersConfig: config) { file in
                    if file != nil {
                        generationState = .complete(file)
                    } else {
                        generationState = .failed
                    }
                }
            } catch {
                errorBinding.appError = AppError.dbError(description: error.localizedDescription)
            }
        }
        
    }
    
    private func onModelChange(endpoint: Endpoint?) {
        if let endpoint = endpoint {
            modelName = endpoint.name
        }
    }
    
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Endpoint.self, configurations: config)
    container.mainContext.insert(Endpoint(name: "qwen7b", modelFamily: .sd))
    container.mainContext.insert(Endpoint(name: "qwen7b", modelFamily: .sd))
    EndpointService.shared.configure(with: container.mainContext)
    
    return ImageGenerateView()
        .environment(ErrorBinding())
}
