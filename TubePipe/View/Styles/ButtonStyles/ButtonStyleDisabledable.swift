//
//  ButtonStyleDisabledable.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-11.
//

import SwiftUI

struct ButtonStyleDisabledable: ButtonStyle {
    let lblColor:Color
    let borderColor:Color
    let backgroundColor:Color
    
    public func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        Disabledable(lblColor:lblColor,
                     borderColor: borderColor,
                     backgroundColor: backgroundColor,
                     configuration: configuration)
    }

    struct Disabledable: View {
        let lblColor:Color
        let borderColor:Color
        let backgroundColor:Color
        let configuration: ButtonStyle.Configuration

        @Environment(\.isEnabled) private var isEnabled: Bool

        var body: some View {
            configuration.label
                .padding([.leading,.trailing],10)
                .padding([.bottom,.top],20)
                .foregroundColor(lblColor)
                .opacity(isEnabled ? 1.0 : 0.6)
                .background(backgroundColor)
                .overlay(
                    Rectangle()
                        .stroke(isEnabled ? borderColor : .black, lineWidth: 2)
                        .opacity(isEnabled ? 1.0 : 0.6)
                )
                .opacity(isEnabled ? (configuration.isPressed ? 0.3 : 1.0) : 0.6)
                .fontWeight(.semibold)
                .disabled(!isEnabled)
        }
    }
}
