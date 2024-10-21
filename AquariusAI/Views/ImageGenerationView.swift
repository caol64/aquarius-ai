//
//  ImageGenerationView.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/1.
//

import SwiftUI
import SwiftData

struct ImageGenerationView: View {
    enum Groups: String {
        case steps
        case scale = "CFG Scale"
        case ratio = "Aspect Ratio"
        case sdxl = "HD"
        case seed
    }
    
    @Environment(AppState.self) private var appState
    @Environment(ModelViewModel.self) private var modelViewModel
    @Environment(ImageGenerationViewModel.self) private var viewModel
    private let modelType: ModelType = .image
    private let title = "Image Generation"
    
    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationSplitView {
            sidebar
                .topAligned()
                .padding(.leading, 16)
                .navigationSplitViewColumnWidth(300)
        } detail: {
            contentView
                .navigationTitle("")
                .navigationSplitViewColumnWidth(min: 750, ideal: 750, max: .infinity)
                .toolbar {
                    ModelPickerToolbar(model: $viewModel.selectedModel, showModelPicker: $viewModel.showModelPicker, title: title, modelType: .image)
                }
                .overlay(alignment: .top) {
                    if viewModel.showModelPicker {
                        ModelListPopup(model: $viewModel.selectedModel, modelType: .image)
                    }
                }
        }
        .onTapGesture {
            viewModel.closeModelListPopup()
        }
        .onChange(of: viewModel.selectedModel) {
            viewModel.onModelChange()
        }
        .onAppear() {
            viewModel.onModelChange()
            appState.openedWindows.insert(.image)
        }
        .onDisappear() {
            appState.openedWindows.remove(.image)
        }
        .monitorWindowFocus(for: .image, appState: appState)
    }
    
    // MARK: - sidebar
    @ViewBuilder
    @MainActor
    private var sidebar: some View {
        @Bindable var viewModel = viewModel
        generationOptions()
        ScrollView {
            prompts
            sdxlGroup(config: $viewModel.config)
                .padding(.top, 8)
                .padding(.trailing, 16)
            Group {
                stepGroup(config: $viewModel.config)
                scaleGroup(config: $viewModel.config)
                ratioGroup(config: $viewModel.config)
                seedGroup(config: $viewModel.config)
            }
            .padding(.trailing, 16)
        }
        HStack {
            Text(viewModel.status)
            Spacer()
            generationButton
        }
        .padding(.bottom, 16)
    }
    
    // MARK: - contentView
    @MainActor
    private var contentView: some View {
        VStack(spacing: 0) {
            Spacer()
            switch viewModel.generationState {
            case .ready:
                ContentUnavailableView {
                    Text("How are you today?")
                }
                .frame(width: 512, height: 512)
            case .failed:
                ContentUnavailableView {
                    Image(systemName: "exclamationmark.triangle")
                }
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
    }
    
    // MARK: - prompts
    @ViewBuilder
    private var prompts: some View {
        @Bindable var viewModel = viewModel
        Text("Prompt")
            .leftAligned()
        TextEditor(text: $viewModel.prompt)
            .padding(.top, 4)
            .frame(height: 100)
            .font(.body)
        Text("Negative Prompt")
            .padding(.top, 4)
            .leftAligned()
        TextEditor(text: $viewModel.negativePrompt)
            .frame(height: 80)
            .font(.body)
    }
    
    // MARK: - stepGroup
    private func stepGroup(config: Binding<DiffusersConfig>) -> some View {
        @Bindable var viewModel = viewModel
        return intSlideGroup(id: Groups.steps.rawValue, expandId: $viewModel.expandId, setting: $viewModel.config.stepCount, range: 1...50, step: 1)
    }
    
    // MARK: - scaleGroup
    private func scaleGroup(config: Binding<DiffusersConfig>) -> some View {
        @Bindable var viewModel = viewModel
        return slideGroup(id: Groups.scale.rawValue, expandId: $viewModel.expandId, setting: $viewModel.config.cfgScale, range: 1...30, step: 0.5, precision: "%.1f")
    }
    
    // MARK: - ratioGroup
    private func ratioGroup(config: Binding<DiffusersConfig>) -> some View {
        @Bindable var viewModel = viewModel
        return exclusiveExpandGroup(id: Groups.ratio.rawValue, expandId: $viewModel.expandId) {
            Picker("", selection: $viewModel.config.imageRatio) {
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
    
    // MARK: - seedGroup
    private func seedGroup(config: Binding<DiffusersConfig>) -> some View {
        @Bindable var viewModel = viewModel
        return intSlideGroup(id: Groups.seed.rawValue, expandId: $viewModel.expandId, setting: $viewModel.config.seed, range: -1...65535, step: 1)
    }
    
    // MARK: - sdxlGroup
    private func sdxlGroup(config: Binding<DiffusersConfig>) -> some View {
        @Bindable var viewModel = viewModel
        return HStack {
            Text(Groups.sdxl.rawValue)
            Spacer()
            Toggle("", isOn: $viewModel.config.isXL)
                .toggleStyle(.switch)
            Button {
                
            } label: {
                Image(systemName: "info.circle")
            }
            .buttonStyle(.plain)
        }
        .padding(.trailing, 4)
    }
    
    // MARK: - generationButton
    @MainActor
    private var generationButton: some View {
        VStack {
            if case .running = viewModel.generationState {
                Button("Cancel") {
                    viewModel.onCancel()
                }
                .frame(width: 100)
            } else {
                Button("Generate") {
                    viewModel.onGenerate()
                }
                .frame(width: 100)
            }
        }
        .buttonStyle(.borderedProminent)
    }
    
    // MARK: - completeView
    @MainActor
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
    
    // MARK: - previewView
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
    
    // MARK: - toolBar
    @MainActor
    private func toolBar(image: CGImage) -> some ToolbarContent {
        @Bindable var viewModel = viewModel
        return ToolbarItemGroup {
            if let model = modelViewModel.fetch(modelType: .upscale).first {
                Button("Upscale", systemImage: "plus.magnifyingglass") {
                    viewModel.onUpscale(image: image, model: model)
                }
            }
            
            Button("Save", systemImage: "square.and.arrow.down") {
                viewModel.showFileExporter = true
            }
            .fileExporter(
                isPresented: $viewModel.showFileExporter,
                document: createPngFileDocument(image: image),
                contentType: .png,
                defaultFilename: "out"
            ) { result in
                switch result {
                case .success(let url):
                    print("File saved to \(url)")
                case .failure(let error):
                    viewModel.handleError(error: error)
                }
            }
        }
    }
    
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Schema([Mlmodel.self]), configurations: config)
    container.mainContext.insert(Mlmodel(name: "qwen7b"))
    container.mainContext.insert(Mlmodel(name: "qwen7b"))
    let appState = AppState()
    let dataRepository = DataRepository(modelContext: container.mainContext)
    let modelViewModel = ModelViewModel(dataRepository: dataRepository)
    
    return ImageGenerationView()
        .environment(appState)
        .environment(modelViewModel)
}
