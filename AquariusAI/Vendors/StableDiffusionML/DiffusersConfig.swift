//
//  SDConfig.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/5/28.
//
import Foundation

@Observable
class DiffusersConfig {
    var stepCount: Int = 6
    var cfgScale: Float = 2.0
    var isXL: Bool = true
    var seed: Int = -1
    var reduceMemory: Bool {
        #if os(macOS)
            return false
        #else
            return true
        #endif
    }
    var imageCount: Int = 1
    var scaleFactor: Float32 = 0.13025
    var imageRatio: ImageRatio = .oneOne
    var width: Int {
        if isXL {
            switch imageRatio {
            case .oneOne:
                return 1024
            case .sixteenNine:
                return 1360
            case .nineSixteen:
                return 768
            }
        } else {
            switch imageRatio {
            case .oneOne:
                return 512
            case .sixteenNine:
                return 680
            case .nineSixteen:
                return 384
            }
        }
    }
    var height: Int {
        if isXL {
            switch imageRatio {
            case .oneOne:
                return 1024
            case .sixteenNine:
                return 768
            case .nineSixteen:
                return 1360
            }
        } else {
            switch imageRatio {
            case .oneOne:
                return 512
            case .sixteenNine:
                return 384
            case .nineSixteen:
                return 680
            }
        }
    }

}

enum ImageRatio: String, CaseIterable, Identifiable {
    case oneOne = "1:1"
    case sixteenNine = "16:9"
    case nineSixteen = "9:16"
    
    var id: Self { self }
}
