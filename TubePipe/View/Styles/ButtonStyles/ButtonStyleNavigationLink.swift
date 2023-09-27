//
//  ButtonStyleNavigationLink.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-30.
//

import SwiftUI
struct ButtonStyleNavigationLink: ButtonStyle {

    public func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .background( .white )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .foregroundColor(Color.white)
            .cornerRadius(16)
            .fontWeight(.semibold)
            .padding()
    }

}
