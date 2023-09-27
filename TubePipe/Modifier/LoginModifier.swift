//
//  LoginModifier.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//

import SwiftUI

struct LoginModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
        .disableAutocorrection(true)
        .autocapitalization(.none)
        .padding()
    }
}
