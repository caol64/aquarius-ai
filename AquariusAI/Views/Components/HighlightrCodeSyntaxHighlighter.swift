//
//  HighlightrCodeSyntaxHighlighter.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/8/15.
//

import Foundation
import MarkdownUI
import SwiftUI
import Highlightr

class HighlightrCodeSyntaxHighlighter: CodeSyntaxHighlighter {
    func highlightCode(_ code: String, language: String?) -> Text {
        guard let highlightr = Highlightr() else {
            return Text(code)
        }
        highlightr.setTheme(to: "monokai")
        let highlightedCode: NSAttributedString?
        if let language, !language.isEmpty {
            highlightedCode = highlightr.highlight(code, as: language)
        } else {
            highlightedCode = highlightr.highlight(code)
        }
        
        guard let highlightedCode else {
            return Text(code)
        }
        
        var attributedCode = AttributedString(highlightedCode)
        attributedCode.font = .system(size: 13, design: .monospaced)
        
        return Text(attributedCode)
    }
    
    
}
