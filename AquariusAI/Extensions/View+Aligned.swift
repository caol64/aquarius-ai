//
//  View+Aligned.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/7/25.
//

import SwiftUI

extension View {
    func rightAligned() -> some View {
        self.modifier(RightAlignedViewModifier())
    }
}

extension View {
    func leftAligned() -> some View {
        self.modifier(LeftAlignedViewModifier())
    }
}

extension View {
    func topAligned() -> some View {
        self.modifier(TopAlignedViewModifier())
    }
}

extension View {
    func bottomAligned() -> some View {
        self.modifier(BottomAlignedViewModifier())
    }
}

struct RightAlignedViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            Spacer()
            content
        }
    }
}

struct LeftAlignedViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            content
            Spacer()
        }
    }
}

struct TopAlignedViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        VStack {
            content
            Spacer()
        }
    }
}

struct BottomAlignedViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        VStack {
            Spacer()
            content
        }
    }
}
