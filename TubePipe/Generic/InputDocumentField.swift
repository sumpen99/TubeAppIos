//
//  InputDocumentField.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-10-09.
//

import SwiftUI

struct InputDocumentField<LabelText: View,Content: View>: View {
    let label:LabelText
    let content: Content

    var body : some View {
        VStack{
            ZStack{
                Text("Description").hidden().hLeading()
                label.bold().foregroundColor(Color.black).hLeading()
            }
            content
        }
    }
}
