//
//  InputDocumentField.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-10-09.
//

import SwiftUI

struct InputDocumentField<Label: View,Content: View>: View {
    let label:Label
    let content: Content

    var body : some View {
        HStack{
            ZStack{
                Text("Description").hidden()
                label.foregroundColor(.blue)
            }
            Divider()
            content.hLeading()
        }
    }
}
