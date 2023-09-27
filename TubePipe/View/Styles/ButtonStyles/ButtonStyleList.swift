//
//  ButtonStyleList.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-06.
//

import SwiftUI

struct ButtonStyleList: ButtonStyle {
    let color:Color
    public func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .background( Color.clear )
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .foregroundColor(color)
            .font(.body)
            .fontWeight(.semibold)
    }

}

struct ButtonStyleSearchContact: ButtonStyle {
    public func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .background( Color.clear )
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .foregroundColor(Color.systemBlue)
            .fontWeight(.semibold)
    }

}
