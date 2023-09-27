//
//  ButtonStyleCard.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-07-27.
//

import SwiftUI
struct ButtonStyleCard: ButtonStyle {
    let color:Color
    public func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .padding(10)
            .background( color )
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .foregroundColor(Color.black)
            .cornerRadius(16)
            .font(.body)
            .fontWeight(.semibold)
    }

}
