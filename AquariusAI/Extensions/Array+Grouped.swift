//
//  Array+Grouped.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/9.
//

import Foundation

extension Array where Element == Models {
    func grouped() -> [String: [Models]] {
        Dictionary(grouping: self) { $0.family.rawValue }
    }
}
