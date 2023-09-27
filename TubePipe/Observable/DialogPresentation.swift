//
//  DialogPresentation.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI

final class DialogPresentation: ObservableObject {
    @Published var isPresented = false
    @Published var stopAnimating = false
    @Published var dialogContent: DialogContent?
    var presentedText:String = ""
    
    func show(content: DialogContent?) {
        withAnimation{
            if let presentDialog = content {
                dialogContent = presentDialog
                isPresented = true
                stopAnimating = false
            } else {
                isPresented = false
                stopAnimating = true
            }
        }
    }
    
    func closeWithAnimationAfter(time:CGFloat){
        DispatchQueue.main.asyncAfter(deadline: .now()){ [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.stopAnimating = true
            DispatchQueue.main.asyncAfter(deadline: .now()+time){[weak self] in
                guard let strongSelf = self else { return }
                strongSelf.isPresented = false
            }
        }
    }
 
}

