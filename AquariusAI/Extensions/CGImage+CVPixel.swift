//
//  CGImage+CVPixel.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/30.
//

//import CoreGraphics
import CoreVideo

extension CGImage {
    
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let width = self.width
        let height = self.height

        var pixelBuffer: CVPixelBuffer?
        let attributes: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         width,
                                         height,
                                         kCVPixelFormatType_32ARGB,
                                         attributes as CFDictionary,
                                         &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pixelData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
            CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
            return nil
        }
        
        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
        
        return buffer
    }
    
}
