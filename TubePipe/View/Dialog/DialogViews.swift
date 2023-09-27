//
//  DialogViews.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI

enum DialogContent: View {
    
    case autofillProgressView(presentedtext: String = "")
    
    @ViewBuilder
    var body: some View {
        switch self {
        case .autofillProgressView(let presentedtext):
            AutoFillProgressView(presentedText: presentedtext)
        }
    }
    
}
    

struct CustomDialog: ViewModifier {
    @ObservedObject var presentationManager: DialogPresentation
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if presentationManager.isPresented {
                Rectangle().foregroundColor(Color.black.opacity(0.3))
                    .edgesIgnoringSafeArea(.all)
                
                presentationManager.dialogContent
                    .padding()
            }
        }
    }
}
