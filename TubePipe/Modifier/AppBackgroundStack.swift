//
//  AppBackgroundStack.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-11.
//
import SwiftUI

struct AppBackgroundStack<Content:View>: View{
    @ViewBuilder var content: Content
    var body: some View {
        ZStack{
            appLinearGradient
            content
        }
        .safeAreaInset(edge: .bottom){ clearSpaceAtBottom }
    }
}

struct AppBackgroundStackWithoutBottomPadding<Content:View>: View{
    @ViewBuilder var content: Content
    var body: some View {
        ZStack{
            appLinearGradient
            content
        }
    }
}
