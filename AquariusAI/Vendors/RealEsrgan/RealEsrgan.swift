//
//  RealEsrgan.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/30.
//

import Foundation
import Vision
import AppKit

class RealEsrgan {
    private let endpoint: Endpoint
    private var model: MLModel?
    
    init(endpoint: Endpoint) {
        self.endpoint = endpoint
    }
    
    deinit {
        
    }
    
    func upscale(image: CGImage) async throws -> CGImage {
        var modelDirectory: URL?
        if let data = endpoint.bookmark {
            modelDirectory = restoreFileAccess(with: data, endpoint: endpoint)
        }
        guard let directory = modelDirectory else {
            throw AppError.bizError(description: "The model path is invalid, please check it in settings.")
        }
        _ = directory.startAccessingSecurityScopedResource()
        if !isDirectoryReadable(path: directory.path()) {
            throw AppError.directoryNotReadable(path: directory.path())
        }
        defer {
            directory.stopAccessingSecurityScopedResource()
        }
        model = try MLModel(contentsOf: directory, configuration: MLModelConfiguration())
        guard let model = model else {
            throw AppError.bizError(description: "Something went wrong, can't load RealEsrgan model on \(directory.path())")
        }
        guard let visionModel = try? VNCoreMLModel(for: model) else {
            throw AppError.bizError(description: "The file \(directory.path()) is not a valid RealEsrgan model.")
        }
        let coreMLRequest = VNCoreMLRequest(model: visionModel)
        coreMLRequest.imageCropAndScaleOption = .scaleFill
        guard let cvPixelBuffer = image.toCVPixelBuffer() else {
            throw AppError.bizError(description: "Something went wrong, the source image is invalid.")
        }
        let handler = VNImageRequestHandler(cvPixelBuffer: cvPixelBuffer, options: [:])
        do {
            try handler.perform([coreMLRequest])
        } catch {
            throw AppError.bizError(description: "Something went wrong: \(error).")
        }
        guard let result = coreMLRequest.results?.first as? VNPixelBufferObservation else {
            throw AppError.bizError(description: "Failed to get result from request.")
        }

        guard let outputImage = result.pixelBuffer.toCGImage() else {
            throw AppError.bizError(description: "Failed to create CGImage from CVPixelBuffer.")
        }

        return outputImage
    }
}
