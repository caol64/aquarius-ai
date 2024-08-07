//
//  ImageGenerationView.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/1.
//

import SwiftUI
import SwiftData

struct ImageGenerationView: View {
    
    enum GenerationState {
        case startup
        case loading
        case running(CGImage?)
        case complete(CGImage)
        case failed
    }
    
    enum Groups: String {
        case steps
        case scale = "CFG Scale"
        case ratio = "Aspect Ratio"
        case sdxl = "HD"
        case seed
    }
    
    @Environment(ErrorBinding.self) private var errorBinding
    @State private var prompt: String = ""
    @State private var negativePrompt: String = ""
    @State private var selectedEndpoint: Endpoint?
    @State private var showFileExporter: Bool = false
    @State private var config: DiffusersConfig = DiffusersConfig()
    @State private var generationState: GenerationState = .startup
    @State private var status: String = ""
    @State private var upscalerEndpoint: Endpoint?
    @State private var showEndpointPicker = false
    @State private var expandId: String?
    @State private var pluginViewModel = PluginViewModel.shared
    @State private var endpointViewModel = EndpointViewModel.shared
    private var modelFamily: ModelFamily = .diffusers
    private let title = "Text Generation"
    
    var body: some View {
        NavigationSplitView {
            VStack {
                generationOptions()
                ScrollView {
                    prompts()
                    sdxlGroup(config: $config)
                        .padding(.top, 8)
                        .padding(.trailing, 16)
                    Group {
                        stepGroup(config: $config)
                        scaleGroup(config: $config)
                        ratioGroup(config: $config)
                        seedGroup(config: $config)
                    }
                    .padding(.trailing, 16)
                }
                HStack {
                    statusBar()
                    Spacer()
                    generationButton()
                }
                .padding(.bottom, 16)
            }
            .topAligned()
            .padding(.leading, 16)
            .navigationSplitViewColumnWidth(300)
        } detail: {
            VStack {
                Spacer()
                switch generationState {
                case .startup:
                    ContentUnavailableView {
                        Text("How are you today?")
                    }
                    .frame(width: 512, height: 512)
                case .failed:
                    ContentUnavailableView {
                        Image(systemName: "exclamationmark.triangle")
                    }
                case .loading:
                    ProgressView()
                        .frame(width: 512, height: 512)
                case .running(let image):
                    if let preview = image {
                        previewView(image: preview)
                    } else {
                        ProgressView()
                            .frame(width: 512, height: 512)
                    }
                case .complete(let image):
                    completeView(image: image)
                }
                Spacer()
            }
            .navigationTitle("")
            .navigationSplitViewColumnWidth(min: 600, ideal: 600, max: .infinity)
            .toolbar {
                EndpointToolbar(endpoint: $selectedEndpoint, showEndpointPicker: $showEndpointPicker, title: title, modelFamily: modelFamily)
            }
            .task {
                onToolBarFetch()
                onModelChange(endpoint: selectedEndpoint)
            }
            .overlay(alignment: .top) {
                if showEndpointPicker {
                    EndpointsList(endpoint: $selectedEndpoint, modelFamily: modelFamily)
                }
            }
            .onChange(of: selectedEndpoint) {
                onModelChange(endpoint: selectedEndpoint)
            }
        }
        .onTapGesture {
            if showEndpointPicker {
                showEndpointPicker = false
            }
        }
//        .frame(minHeight: 530)
    }
    
    private func prompts() -> some View {
        VStack {
            Text("Prompt")
                .leftAligned()
            TextEditor(text: $prompt)
                .padding(.top, 4)
                .frame(height: 100)
                .font(.body)
            Text("Negative Prompt")
                .padding(.top, 4)
                .leftAligned()
            TextEditor(text: $negativePrompt)
                .frame(height: 80)
                .font(.body)
        }
    }
    
    private func stepGroup(config: Binding<DiffusersConfig>) -> some View {
        intSlideGroup(id: Groups.steps.rawValue, expandId: $expandId, setting: $config.stepCount, range: 1...50, step: 1)
    }
    
    private func scaleGroup(config: Binding<DiffusersConfig>) -> some View {
        doubleSlideGroup(id: Groups.scale.rawValue, expandId: $expandId, setting: $config.cfgScale, range: 1...30, step: 0.5, precision: "%.1f")
    }
    
    private func ratioGroup(config: Binding<DiffusersConfig>) -> some View {
        exclusiveExpandGroup(id: Groups.ratio.rawValue, expandId: $expandId) {
            Picker("", selection: $config.imageRatio) {
                ForEach(ImageRatio.allCases) { ratio in
                    Text(ratio.rawValue)
                        .tag(ratio)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        } label: {
            HStack {
                Text(Groups.ratio.rawValue)
                Spacer()
                Text(config.wrappedValue.imageRatio.rawValue)
                Button {
                    
                } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func seedGroup(config: Binding<DiffusersConfig>) -> some View {
        intSlideGroup(id: Groups.seed.rawValue, expandId: $expandId, setting: $config.seed, range: -1...65535, step: 1)
    }
    
    private func sdxlGroup(config: Binding<DiffusersConfig>) -> some View {
        HStack {
            Text(Groups.sdxl.rawValue)
            Spacer()
            Toggle("", isOn: $config.isXL)
                .toggleStyle(.switch)
            Button {
                
            } label: {
                Image(systemName: "info.circle")
            }
            .buttonStyle(.plain)
        }
        .padding(.trailing, 4)
    }
    
    private func generationButton() -> some View {
        VStack {
            if case .running = generationState {
                Button("Cancel") {
                    onCancel()
                }
                .frame(width: 100)
            } else if case .loading = generationState {
                Button("Generate") {
                }
                .disabled(true)
                .frame(width: 100)
            } else {
                Button("Generate") {
                    onGenerate()
                }
                .frame(width: 100)
            }
        }
        .buttonStyle(.borderedProminent)
    }
    
    private func completeView(image: CGImage) -> some View {
        VStack {
            Image(image, scale: 1.0, label: Text(""))
                .resizable()
                .scaledToFit()
        }
//        .aspectRatio(contentMode: .fit)
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
//        .aspectRatio(contentMode: .fit)
        .frame(width: 512, height: 512)
        .cornerRadius(15)
    }
    
    private func statusBar() -> some View {
        Text(status)
    }
    
    private func toolBar(image: CGImage) -> some ToolbarContent {
        ToolbarItemGroup {
            if upscalerEndpoint != nil {
                Button("Upscale", systemImage: "plus.magnifyingglass") {
                    onUpscale(image: image)
                }
            }
            
            Button("Save", systemImage: "square.and.arrow.down") {
                showFileExporter = true
            }
            .fileExporter(
                isPresented: $showFileExporter,
                document: createPngFileDocument(image: image),
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
            return
        }
        status = ""
        guard let endpoint = selectedEndpoint else {
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
                    status = "Model loaded in \(String(format: "%.1f", interval)) s."
                    generationState = .running(nil)
                } onGenerateComplete: { file, interval in
                    if let image = file {
                        generationState = .complete(image)
                        status = "Image generated in \(String(format: "%.1f", interval)) s."
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
            config.isXL = endpoint.name.lowercased().contains("xl")
        }
    }
    
    private func onCancel() {
        //        DiffusersPipeline.shared?.cancelGenerate()
        generationState = .startup
    }
    
    private func onToolBarFetch() {
        let upscalerPlugin = pluginViewModel.get(family: .upscaler)
        if let plugin = upscalerPlugin, let endpointId = plugin.endpointId {
            upscalerEndpoint = endpointViewModel.get(id: endpointId)
        }
    }
    
    private func onUpscale(image: CGImage) {
        guard let endpoint = upscalerEndpoint else {
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
    let errorBinding = ErrorBinding()
    EndpointViewModel.shared.configure(modelContext: container.mainContext, errorBinding: errorBinding)
    
    return ImageGenerationView()
        .environment(errorBinding)
}
