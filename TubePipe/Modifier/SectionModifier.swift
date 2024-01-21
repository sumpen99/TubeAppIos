//
//  SectionModifier.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//

import SwiftUI

struct SectionHeaderModifier: ViewModifier{
    func body(content: Content) -> some View{
        content
            .font(.system(size: 20,weight: .black).monospacedDigit())
            .foregroundStyle(.white)
    }
}
