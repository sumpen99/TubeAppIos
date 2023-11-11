//
//  ButtonStyleDocument.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-07-23.
//

import SwiftUI
struct ButtonStyleDocument: ButtonStyle {

    public func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .padding([.leading,.trailing],10)
            .padding([.bottom,.top],20)
            .background( Color.backgroundSecondary )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.black, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .foregroundColor(Color.black)
            .fontWeight(.semibold)
    }

}
