//
//  NSImage+PngData.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/26.
//

import AppKit.NSImage

extension NSImage {
    func pngData() -> Data? {
        guard let tiffRepresentation = self.tiffRepresentation else { return nil }
        guard let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }
}

extension NSImage {
    convenience init?(cvPixelBuffer: CVPixelBuffer) {
        let ciImage = CIImage(cvPixelBuffer: cvPixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        self.init(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
    }
    
}
