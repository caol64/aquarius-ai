//
//  UTType+MLmodel.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/29.
//

import UniformTypeIdentifiers

extension UTType {
    static var mlmodel: UTType {
        UTType(importedAs: "com.apple.coreml.model")
    }

    static var mlmodelc: UTType {
        UTType(importedAs: "com.apple.coreml.compiledModel")
    }
}
