//
//  ButtonStyleFillListRow.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-08.
//

import SwiftUI
struct ButtonStyleFillListRow: ButtonStyle {
    public func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .hFill()
            .background( Color.white )
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .cornerRadius(16)
   }

}
