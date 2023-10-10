//
//  FeatureView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-10-08.
//

import SwiftUI

struct FeatureView:View{
    @State var docContent: DocumentContent = DocumentContent()
    @FocusState var focusField: Field?
    
    var buttonIsDisabled:Bool{
        false
    }
    
    var featureHeader:some View{
        Text("New Feature Request")
        .font(.title)
        .bold()
        .foregroundColor(Color.GHOSTWHITE)
        .hLeading()
    }
    
    var featureFooter:some View{
        Text("Fill out the following form to submit a new feature request.")
        .listSectionFooter()
        .hLeading()
    }
    
    var featureTopHeader:some View{
        VStack{
            featureHeader
            featureFooter
        }
        .padding()
    }
    
    var inputTitle:some View{
        InputDocumentField(label: Text("Title"),content:
                            TextField("",text:$docContent.title.max(MAX_TEXTFIELD_LEN),axis: .vertical)
                                .preferedDocumentField()
                                .focused($focusField,equals: .DOCUMENT_TITLE)
                                .placeholder("title",when: focusField != .DOCUMENT_TITLE)
        )
        .fieldFirstResponder{
            focusField = .DOCUMENT_TITLE
        }
       
    }
    
    var inputDescription:some View{
        InputDocumentField(label: Text("Description").vTop(),content:
                            HStack{
                            TextField("",text:$docContent.message.max(MAX_TEXTFIELD_LEN),axis: .vertical)
                                .preferedDocumentField()
                                .focused($focusField,equals: .DOCUMENT_MESSAGE)
                                .placeholder("message",
                                             when: (focusField != .DOCUMENT_MESSAGE) && (docContent.message.isEmpty)).vTop()
                            Text("\(MAX_TEXTFIELD_LEN-docContent.message.count)").font(.caption).foregroundColor(Color.systemGray).hTrailing().frame(width:33.0).vBottom()}
        )
        .frame(height: 250.0)
        .fieldFirstResponder{
            focusField = .DOCUMENT_MESSAGE
        }
    }
    
    var inputScreenshot:some View{
        InputDocumentField(label: Text("Screenshot"),
                           content: ImagePickerSwiftUi(docContent: $docContent,
                                                       label: Label("(optional)",
                                                                    systemImage: "photo.on.rectangle.angled")))
    }
    
    var shareButton: some View{
        Button(action: { },label: {
            Text("Send").hCenter()
        })
        .disabled(buttonIsDisabled)
        .buttonStyle(ButtonStyleDisabledable(lblColor:Color.black))
        .padding()
    }
    
    var inputBody:some View {
        VStack{
            inputTitle
            Divider()
            inputDescription
            Divider()
            inputScreenshot
            Divider()
        }
        
        
    }
    
   
    var infoBody:some View{
        VStack(spacing:0){
            featureTopHeader
            List{
                inputBody
            }
            .listStyle(.insetGrouped)
            shareButton
        }
        
    }
    
    var body:some View{
        NavigationView{
            AppBackgroundStack(content: {
                infoBody
            })
            .modifier(NavigationViewModifier(title: ""))
        }
        .hiddenBackButtonWithCustomTitle("Profile")
    }
}
