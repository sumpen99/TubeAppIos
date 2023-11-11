//
//  FeatureView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-10-08.
//

import SwiftUI

struct FeatureView:View{
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @EnvironmentObject var globalLoadingPresentation: GlobalLoadingPresentation
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
        docContent.isNotAValidDocument
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
    
    var optionalText:some View{
        Text("optional").italic().foregroundColor(.tertiaryLabel)
    }
    
    var optionalImage:some View{
        HStack{
            optionalText
            Image(systemName: "photo.on.rectangle.angled")
        }
        .italic()
        .foregroundColor(.tertiaryLabel)
        
    }
    
    var inputTitle:some View{
        InputDocumentField(label: Text("Title"),content:
                            TextField("",text:$docContent.title.max(MAX_TEXTFIELD_LEN),onCommit: {})
                                .preferedDocumentField()
                                .focused($focusField,equals: .DOCUMENT_TITLE)
                                .placeholder("feature",
                                             when: (focusField != .DOCUMENT_TITLE && docContent.title.isEmpty))
                                .lineLimit(1)
                                
        )
        .hLeading()
        
    }
    
    var inputDescription:some View{
        InputDocumentField(label: Text("Description").vTop(),content:
                            ZStack{
            TextField("",text:$docContent.message.max(MAX_TEXTFIELD_LEN*4),axis:.vertical)
                                .preferedDocumentField()
                                .focused($focusField,equals: .DOCUMENT_MESSAGE)
                                .placeholder("message",
                                             when: (focusField != .DOCUMENT_MESSAGE) && (docContent.message.isEmpty))
                                .vTop()
                            Text("\(MAX_TEXTFIELD_LEN*4-docContent.message.count)")
                            .font(.caption)
                            .foregroundColor(Color.systemGray)
                            .frame(width:33.0)
                            .vBottom()
                            .hTrailing()
                        }
        )
        .frame(height: 250.0)
    }
    
    var inputEmail:some View{
        InputDocumentField(label: Text("Email"),content:
                            TextField("",text:$docContent.email.max(MAX_TEXTFIELD_LEN),onCommit: {})
                                .preferedDocumentField()
                                .focused($focusField,equals: .DOCUMENT_EMAIL)
                                .placeholder(when: (focusField != .DOCUMENT_EMAIL && docContent.email.isEmpty)){
                                    optionalText.padding(.leading)
                                }
                                .lineLimit(1)
        )
     }
    
    var inputScreenshot:some View{
        InputDocumentField(label: Text("Screenshot"),
                           content: ImagePickerSwiftUi(docContent: $docContent,
                                                       label: optionalImage)
                            .buttonStyle(BorderlessButtonStyle())
        )
        .buttonStyle(BorderlessButtonStyle())
        .fullListWidthSeperator()
     }
    
    var shareButton: some View{
        Button(action: submitFeatureRequest ,label: {
            Text("Submit").hCenter()
        })
        .disabled(buttonIsDisabled)
        .buttonStyle(ButtonStyleDisabledable(lblColor:Color.black,backgroundColor: Color.white))
        .padding()
    }
           
    var infoBody:some View{
        VStack(spacing:0){
            featureTopHeader
            List{
                inputTitle
                inputDescription
                inputEmail
                inputScreenshot
                shareButton
            }
            .listStyle(.insetGrouped)
        }
        
    }
    
    var body:some View{
        AppBackgroundStack(content: {
            infoBody
        })
        .modifier(NavigationViewModifier(title: ""))
        .hiddenBackButtonWithCustomTitle("Profile")
        .alert("Feature request sent",
               isPresented: $submitHasBeenMade,
               actions: { Button("Thank you!", role: .cancel) { clearDocument() }},
               message: { Text("\(thankRequester)") })
    }
    
    func clearDocument(){
        docContent.clearDocument()
        focusField = nil
    }
    
    func submitFeatureRequest(){
        docContent.trim()
        let featureId = docContent.documentId
        let storageId = docContent.storageId
        let email = docContent.enteredEmail
        let feature = FeatureRequest(featureId: featureId,
                                     email: email,
                                     title: docContent.title,
                                     description: docContent.message,
                                     date: Date(),
                                     storageId: storageId)
        
        globalLoadingPresentation.startLoading()
        firestoreViewModel.submitNewFeatureRequest(feature,
                                                   featureId: featureId,
                                                   imgData: docContent.data){result in
            globalLoadingPresentation.stopLoading(isSuccess:result.isSuccess,
                                                  message: result.message,
                                                  showAnimationCircle: false)
            if result.isSuccess{ submitHasBeenMade.toggle() }
        }
        
    }
    
}
