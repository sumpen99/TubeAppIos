//
//  ButtonStyleDisabledable.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-11.
//

import SwiftUI

struct ButtonStyleDisabledable: ButtonStyle {
    let lblColor:Color
    let backgroundColor:Color
    
    public func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        Disabledable(lblColor:lblColor,
                     backgroundColor: backgroundColor,
                     configuration: configuration)
    }

    struct Disabledable: View {
        let lblColor:Color
        let backgroundColor:Color
        let configuration: ButtonStyle.Configuration

        @Environment(\.isEnabled) private var isEnabled: Bool

        var body: some View {
            configuration.label
                .padding([.leading,.trailing],10)
                .padding([.bottom,.top],20)
                .foregroundColor(lblColor)
                .background(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.black, lineWidth: 1)
                        .opacity(isEnabled ? 0.3 : 1.0)
                )
                .opacity(isEnabled ? (configuration.isPressed ? 0.3 : 1.0) : 0.3)
                .fontWeight(.semibold)
                .disabled(!isEnabled)
        }
    }
}
