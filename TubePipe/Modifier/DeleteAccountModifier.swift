//
//  DeleteAccountModifier.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-17.
//

import SwiftUI

struct DeleteAccountModifier: ViewModifier {
    @Binding var isPresented:Bool
    @State var password:String = ""
    let email:String
    let onAction: (String,String) -> Void
    func body(content: Content) -> some View{
        content
        .alert("Delete account", isPresented: $isPresented){
            SecureField("Password", text: $password)
            Button("Delete", role: .destructive,action: { onAction(email,password) })
            Button("Cancel",role: .cancel,action:{ })
        } message: {
            Text("Please enter your credentials to confirm action.\nAll data stored on device will be removed.\n\n\(email)")
        }
    }
}
