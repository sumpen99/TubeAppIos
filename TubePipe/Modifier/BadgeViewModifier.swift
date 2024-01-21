//
//  BadgeViewModifier.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-20.
//

import SwiftUI
struct BadgeViewModifier: ViewModifier {
    let text: String?
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                text.map { value in
                    Text(value)
                        .fixedSize(horizontal: true, vertical: false)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, value.count == 1 ? 2 : 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.systemRed)
                                .if(value.count == 1) { $0.aspectRatio(1, contentMode: .fill) }
                        )
                }
            }
    }
}
