//
//  ButtonStyleDisabledable.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-11.
//

import SwiftUI

struct ButtonStyleDisabledable: ButtonStyle {
    let lblColor:Color
    
    public func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        Disabledable(lblColor:lblColor,
                     configuration: configuration)
    }

    struct Disabledable: View {
        let lblColor:Color
        let configuration: ButtonStyle.Configuration

        @Environment(\.isEnabled) private var isEnabled: Bool

        var body: some View {
            configuration.label
                .padding([.leading,.trailing],10)
                .padding([.bottom,.top],20)
                .foregroundColor(isEnabled ? lblColor : Color.placeholderText)
                .background(appButtonGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black, lineWidth: 1)
                )
                .opacity(isEnabled ? (configuration.isPressed ? 0.5 : 1.0) : 0.5)
                .cornerRadius(16)
                .fontWeight(.semibold)
                .disabled(!isEnabled)
        }
    }
}
