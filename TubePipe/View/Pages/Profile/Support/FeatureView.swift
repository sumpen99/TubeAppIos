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
    @State var submitHasBeenMade:Bool = false
    let thankRequester =
        """
        Thank you for contacting us.
        You’re helping us make TubePipe better! We couldn’t be more grateful for your request. Your opinion matters, is hugely appreciated, and we’ll take that into consideration going forward. Hopefully we`ll be able to incorparate your feature in upcoming versions.
        
        Thank you once again,
        /TubePipe
        """
    
    
    var buttonIsDisabled:Bool{
        (docContent.title.isEmpty||docContent.message.isEmpty)
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
                                .placeholder("(required field)",when: focusField != .DOCUMENT_TITLE)
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
                                .placeholder("(required field)",
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
                                                                    systemImage: "photo.on.rectangle.angled").vTop()))
    }
    
    var shareButton: some View{
        Button(action: { submitHasBeenMade.toggle() },label: {
            Text("Submit").hCenter()
        })
        .disabled(buttonIsDisabled)
        .buttonStyle(ButtonStyleDisabledable(lblColor:Color.blue,backgroundColor: Color.GHOSTWHITE))
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
        .confirmationDialog("Feature request sent",
                            isPresented: $submitHasBeenMade,
                            titleVisibility: .visible){
            Button("Thank you!", role: .cancel){}
        } message: {
            Text("\(thankRequester)")
        }
    }
}

/*
 If you`re having trouble in some part of the app you`ve come to thew right place. Please use this form to
 tell us about the issue you`re experience.
 
 Please provide a detailed description of the issue, including:
 1. What you were doing when the problem occurred
 2. What you expect to happen
 3. What actually happen.
 4. Is this problem consistent or does it come and go.
 
 
 */
