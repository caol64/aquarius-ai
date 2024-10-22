//
//  MarkdownUI+Theme.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/10/22.
//

import MarkdownUI
import SwiftUI

extension MarkdownUI.Theme {
    static let customGitHub = Theme.gitHub
        .text {
            FontSize(14)
        }
        .code {
            FontFamilyVariant(.monospaced)
            FontSize(.em(0.85))
            BackgroundColor(Color(hex: "#FAFAFA"))
            ForegroundColor(Color(hex: "#8D8D8D"))
        }
        .codeBlock { configuration in
            VStack(spacing: 0) {
                CodeblockTitleView(configuration: configuration)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(light: Color(rgba: 0xf7f7_f9ff), dark: Color(rgba: 0x2526_2aff)))
                ScrollView(.horizontal) {
                    configuration.label
                        .fixedSize(horizontal: false, vertical: true)
                        .relativeLineSpacing(.em(0.225))
                        .markdownTextStyle {
                            FontFamilyVariant(.monospaced)
                            FontSize(.em(0.85))
                        }
                        .padding(16)
                }
                .background(Color(light: Color(rgba: 0xf7f7_f9ff), dark: Color(rgba: 0x2526_2aff)))
                .markdownMargin(top: 0, bottom: 16)
            }
            .cornerRadius(8)
        }

}

struct CodeblockTitleView: View {
    @Environment(TextGenerationViewModel.self) private var viewModel
    @State private var isCodeblockCopied = false
    var configuration: CodeBlockConfiguration
    var body: some View {
        HStack {
            Text(configuration.language?.capitalized ?? "plain text")
                .foregroundStyle(Color(hex: "#8D8D8D"))
            Spacer()
            Button(action: {
                viewModel.onCodeblockCopy(code: configuration.content)
                withAnimation {
                    isCodeblockCopied = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        self.isCodeblockCopied = false
                    }
                }
            }) {
                Label(isCodeblockCopied ? "Copied!" : "Copy Code", systemImage: isCodeblockCopied ? "checkmark" : "square.on.square.fill")
                    .foregroundColor(Color(hex: "#8D8D8D"))
            }
        }
    }
    
}
