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
            .foregroundStyle(color)
            .toolbarFontAndPadding(.headline)
            .fontWeight(.bold)
    }

}
