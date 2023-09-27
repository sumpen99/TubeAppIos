//
//  ButtonStyleSheet.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-11.
//
import SwiftUI
struct ButtonStyleSheet: ButtonStyle {

    public func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .padding([.leading,.trailing],10)
            .padding([.bottom,.top],20)
            .background( appButtonGradient )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .foregroundColor(Color.white)
            .cornerRadius(16)
            .fontWeight(.semibold)
    }

}

