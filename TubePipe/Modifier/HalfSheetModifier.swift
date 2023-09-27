//
//  HalfSheetModifier.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-19.
//

import SwiftUI

struct HalfSheetModifier:ViewModifier{
    func body(content: Content) -> some View{
        content
        .background(
            halfSheetBackgroundColor
        )
        .ignoresSafeArea()
    }
}

struct HalfSheetDocumentModifier:ViewModifier{
    func body(content: Content) -> some View{
        content
        .background(
            halfSheetBackgroundColor
        )
        .ignoresSafeArea()
    }
}
