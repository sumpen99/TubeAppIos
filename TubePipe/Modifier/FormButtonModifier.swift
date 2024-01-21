//
//  FormButtonModifier.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//

import SwiftUI

struct FormButtonModifier: ViewModifier{
    var width:CGFloat
    var backgroundColor: Color
    func body(content: Content) -> some View{
        content
            .font(.headline)
            .foregroundStyle(.white)
            .padding()
            .frame(width: width, height: 50)
            .background(backgroundColor)
            .cornerRadius(15.0)
    }
}
