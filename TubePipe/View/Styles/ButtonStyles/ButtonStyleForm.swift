//
//  ButtonStyleForm.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-11.
//
import SwiftUI
struct ButtonStyleForm: ButtonStyle {

    public func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .padding([.leading,.trailing],10)
            .padding([.bottom,.top],20)
            .background( appButtonGradient )
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .foregroundColor(Color.white)
            .cornerRadius(16)
            .fontWeight(.semibold)
    }

}
