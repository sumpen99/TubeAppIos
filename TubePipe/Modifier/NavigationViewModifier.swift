//
//  NavigationViewModifier.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//

import SwiftUI

struct NavigationViewModifier: ViewModifier {
    let title:String
    func body(content: Content) -> some View {
        content
        //.listStyle(GroupedListStyle())
        //.listRowBackground(Color(.systemGroupedBackground))
        .scrollContentBackground(.hidden)
        //.background( APP_BACKGROUND_COLOR )
        //.edgesIgnoringSafeArea(.all)
        .background( appLinearGradient )
        .navigationBarTitle(title,displayMode: .inline)
        //.navigationBarHidden(true)
    }
}
