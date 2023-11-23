//
//  TextfieldViews.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI

struct BaseTubeTextField:View {
    @Binding var docContent: DocumentContent
    @FocusState var focusField: Field?
    var placeHolder:String = "message"
    
    var message:some View{
        HStack{
            Image(systemName: "doc.text.image").vTop()
            TextField("",text:$docContent.message.max(MAX_TEXTFIELD_LEN),axis: .vertical)
                .preferedDocumentField()
                .lineLimit(nil)
                .focused($focusField,equals: .DOCUMENT_MESSAGE)
                .placeholder(when: focusField != .DOCUMENT_MESSAGE && docContent.message.isEmpty){ Text(placeHolder).font(.caption).listSectionFooter()}
                .vTop()
            Text("\(MAX_TEXTFIELD_LEN-docContent.message.count)").font(.caption)
            .hTrailing()
            .frame(width:33.0)
            .vBottom()
        }
        .frame(height: 250.0)
    }
    
    var body: some View{
        VStack(spacing:20){
            message
        }
        .roundedBorder()
    }
    
}
