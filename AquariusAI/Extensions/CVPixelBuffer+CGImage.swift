//
//  CVPixelBuffer+CGImage.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/30.
//

import CoreVideo

extension CVPixelBuffer {
    func toCGImage() -> CGImage? {
        CVPixelBufferLockBaseAddress(self, .readOnly)
                
        defer {
            CVPixelBufferUnlockBaseAddress(self, .readOnly)
        }
        
        guard let baseAddress = CVPixelBufferGetBaseAddress(self) else {
            return nil
        }
        
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(self)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        
        guard let context = CGContext(data: baseAddress,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        
        return context.makeImage()
    }
}
