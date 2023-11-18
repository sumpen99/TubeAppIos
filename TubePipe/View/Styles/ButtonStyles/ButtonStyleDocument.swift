//
//  ButtonStyleDocument.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-07-23.
//

import SwiftUI
struct ButtonStyleDocument: ButtonStyle {
    var color:Color = Color.backgroundSecondary
    public func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .padding([.leading,.trailing],10)
            .padding([.bottom,.top],20)
            .background( color )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.black, lineWidth: 2)
            )
            .cornerRadius(24)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .foregroundColor(Color.black)
            .fontWeight(.semibold)
    }

}
