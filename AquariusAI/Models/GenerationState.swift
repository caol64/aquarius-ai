//
//  GenerationState.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/10/21.
//

enum GenerationState<T> {
    case ready
    case running(T?)
    case complete(T)
    case failed
}
