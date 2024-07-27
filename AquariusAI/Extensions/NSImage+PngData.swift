//
//  NSImage+PngData.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/26.
//

import SwiftUI

extension NSImage {
    func pngData() -> Data? {
        guard let tiffRepresentation = self.tiffRepresentation else { return nil }
        guard let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }
}
