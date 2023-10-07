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
    
    var message:some View{
        VStack(spacing:5.0){
            HStack{
                Image(systemName: "doc.text.image").foregroundColor(.systemGray)
                TextField("",text:$docContent.message.max(MAX_TEXTFIELD_LEN),axis: .vertical)
                    .preferedDocumentField()
                    .focused($focusField,equals: .DOCUMENT_MESSAGE)
                    .placeholder("message",
                                 when: (focusField != .DOCUMENT_MESSAGE) && (docContent.message.isEmpty))
                Text("\(MAX_TEXTFIELD_LEN-docContent.message.count)").font(.caption).foregroundColor(Color.systemGray).hTrailing().frame(width:33.0)
                
            }
            .vTop()
            .fieldFirstResponder{
                focusField = .DOCUMENT_MESSAGE
            }
       }
        
    }
    
    var body: some View{
        VStack(spacing:20){
            //title
            message
        }
        .halfSheetWhitePadding()
    }
    
}

struct TextFieldSection:View{
    @EnvironmentObject var tubeViewModel: TubeViewModel
    @Binding var textfieldValue:String
    let header:String
    let subHeader:String
    let isNotAlignmentSection:Bool = true
    
    var body: some View{
        Section(header:HeaderSubHeaderView(header:header,subHeader: subHeader)){
            TextField("\(textfieldValue)",
                      text: $textfieldValue).preferedSettingsField()
        }
        .hLeading()
        Divider()
        
    }
}