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
    var reduceMemory: Bool = false
    var imageCount: Int = 1
    var scaleFactor: Float32 = 0.13025

}
