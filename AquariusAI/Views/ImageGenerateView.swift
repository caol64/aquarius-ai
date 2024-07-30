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
        case loading
        case running(CGImage?)
        case complete(CGImage)
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
    @State private var status: String = ""
    @State private var upscalerEndpoints: [Endpoint] = []
    
    var body: some View {
        NavigationSplitView {
            VStack() {
                genrateOptions()
                prompts()
                EndpointPicker(endpoint: $endpoint, modelFamily: .diffusers)
                    .padding(.top, 4)
                    .onChange(of: endpoint) {
                        onModelChange(endpoint: endpoint)
                    }
                generationConfigs(config: $config)
                generationButton()
                    .padding(.top, 4)
                statusBar()
            }
            .topAligned()
            .padding()
            .navigationSplitViewColumnWidth(300)
        } detail: {
            VStack {
                switch generationState {
                case .startup:
                    Image(systemName: "photo")
                case .failed:
                    Image(systemName: "exclamationmark.triangle")
                case .loading:
                    ProgressView()
                case .running(let image):
                    if let preview = image {
                        previewView(image: preview)
                    } else {
                        ProgressView()
                    }
                case .complete(let image):
                    completeView(image: image)
                }
            }
            .navigationTitle(modelName)
//            .navigationSubtitle(modelName)
            .navigationSplitViewColumnWidth(min: 600, ideal: 600, max: 900)
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
            
            Picker(selection: $config.imageRatio, label: Text("Image Ratio")) {
                ForEach(ImageRatio.allCases) {
                    Text($0.rawValue)
                        .tag($0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Toggle(isOn: $config.isXL) {
                Text("XL")
            }
            .leftAligned()
            .padding(.top, 4)
        }
    }
    
    private func generationButton() -> some View {
        VStack {
            if case .running = generationState {
                Button("  Cancel  ") {
                    onCancel()
                }
            } else if case .loading = generationState {
                Button("Generate") {
                }
                .disabled(true)
            } else {
                Button("Generate") {
                    onGenerate()
                }
            }
        }
        .buttonStyle(.borderedProminent)
        .rightAligned()
    }
    
    private func completeView(image: CGImage) -> some View {
        VStack {
            Image(image, scale: 1.0, label: Text(""))
                .resizable()
                .scaledToFit()
        }
        .aspectRatio(contentMode: .fit)
        .frame(width: 512, height: 512)
        .cornerRadius(15)
        .toolbar {
            toolBar(image: image)
        }
    }
    
    private func previewView(image: CGImage) -> some View {
        VStack {
            ZStack {
                Image(image, scale: 1.0, label: Text(""))
                    .resizable()
                    .scaledToFit()
                
                ProgressView()
            }
        }
        .aspectRatio(contentMode: .fit)
        .frame(width: 512, height: 512)
        .cornerRadius(15)
    }
    
    private func statusBar() -> some View {
        Text(status)
            .bottomAligned()
            .leftAligned()
    }
    
    private func toolBar(image: CGImage) -> some View {
        HStack {
            if !upscalerEndpoints.isEmpty {
                Button("Upscale", systemImage: "plus.magnifyingglass") {
                    onUpscale(image: image)
                }
            }
            
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
        .task {
            await onToolBarFetch()
        }
    }
    
    // MARK: - Actions
    private func onGenerate() {
        if case .running = generationState {
            return
        }
        if prompt.isEmpty {
            errorBinding.appError = AppError.promptEmpty
            return
        }
        status = ""
        guard let endpoint = endpoint else {
            errorBinding.appError = AppError.missingModel
            return
        }
        Task {
            do {
                generationState = .loading
                status = "Loading model..."
                let pipeline = DiffusersPipeline(endpoint: endpoint, diffusersConfig: config)
                generationState = .running(nil)
                try await pipeline.generate(prompt: prompt, negativePrompt: negativePrompt) { interval in
                    status = "Model loaded successfully in \(String(format: "%.1f", interval)) s."
                    generationState = .running(nil)
                } onGenerateComplete: { file, interval in
                    if let image = file {
                        generationState = .complete(image)
                        status = "Generate successfully in \(String(format: "%.1f", interval)) s."
                    } else {
                        generationState = .failed
                        status = "Generate failed."
                    }
                } onProgress: { progress in
                    status = "Generating progress \(progress.step + 1) / \(progress.stepCount) ..."
                    generationState = .running(progress.currentImages[0])
                }
            } catch {
                errorBinding.appError = AppError.dbError(description: error.localizedDescription)
                status = "Generate failed."
                generationState = .failed
            }
        }
        
    }
    
    private func onModelChange(endpoint: Endpoint?) {
        if let endpoint = endpoint {
            modelName = endpoint.name
            config.isXL = modelName.lowercased().contains("xl")
        }
    }
    
    private func onCancel() {
//        DiffusersPipeline.shared?.cancelGenerate()
        generationState = .startup
    }
    
    private func onToolBarFetch() async {
        do {
            upscalerEndpoints = try await EndpointService.shared.fetch(modelFamily: .upscaler)
        } catch {
            errorBinding.appError = AppError.dbError(description: error.localizedDescription)
        }
    }
    
    private func onUpscale(image: CGImage) {
        guard let endpoint = upscalerEndpoints.first else {
            return
        }
        let model = RealEsrgan(endpoint: endpoint)
        Task {
            do {
                status = "Upscaling..."
                generationState = .running(image)
                let result = try await model.upscale(image: image)
                generationState = .complete(result)
                status = "Upscale successfully"
            } catch {
                errorBinding.appError = AppError.dbError(description: error.localizedDescription)
                status = "Upscale failed."
                generationState = .failed
            }
        }
        
    }
    
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Endpoint.self, configurations: config)
    container.mainContext.insert(Endpoint(name: "qwen7b", modelFamily: .diffusers))
    container.mainContext.insert(Endpoint(name: "qwen7b", modelFamily: .diffusers))
    EndpointService.shared.configure(with: container.mainContext)
    
    return ImageGenerateView()
        .environment(ErrorBinding())
}
