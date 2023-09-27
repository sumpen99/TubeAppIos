//
//  ButtonStyleProfile.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-07-30.
//

import SwiftUI
struct ButtonStyleProfile: ButtonStyle {
    var colorForeground:Color = Color.WHITESMOKE
    var colorBackground:Color = Color.tertiarySystemFill
    public func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .font(.system(.title3, design: .rounded))
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .foregroundColor(colorForeground)
            .background(colorBackground )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.black, lineWidth: 1)
            )
            .cornerRadius(4)
            /*.padding()
            .background( colorBackground )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.black, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .foregroundColor(colorForeground)
            .cornerRadius(4)
            .font(.callout)*/
            //.fontWeight(.semibold)
    }

}
