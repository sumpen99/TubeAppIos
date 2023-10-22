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
                                .placeholder("...",
                                             when: (focusField != .DOCUMENT_TITLE && docContent.title.isEmpty),
                                             alignment: .center)
        )
        .fieldFirstResponder{
            focusField = .DOCUMENT_TITLE
        }
       
    }
    
    var inputDescription:some View{
        InputDocumentField(label: Text("Description").vTop(),content:
                            ZStack{
            TextField("",text:$docContent.message.max(MAX_TEXTFIELD_LEN*4),axis: .vertical)
                                .preferedDocumentField()
                                .focused($focusField,equals: .DOCUMENT_MESSAGE)
                                .placeholder("...",
                                             when: (focusField != .DOCUMENT_MESSAGE) && (docContent.message.isEmpty),
                                             alignment: .center)
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
        .fieldFirstResponder{
            focusField = .DOCUMENT_MESSAGE
        }
    }
    
    var inputEmail:some View{
        InputDocumentField(label: Text("Email"),content:
                            TextField("",text:$docContent.email.max(MAX_TEXTFIELD_LEN),axis: .vertical)
                                .preferedDocumentField()
                                .focused($focusField,equals: .DOCUMENT_EMAIL)
                                .placeholder("(optional)",
                                             when: (focusField != .DOCUMENT_EMAIL && docContent.email.isEmpty),
                                             alignment: .center)
        )
        .fieldFirstResponder{
            focusField = .DOCUMENT_EMAIL
        }
       
    }
    
    var inputScreenshot:some View{
        InputDocumentField(label: Text("Screenshot"),
                           content: ImagePickerSwiftUi(docContent: $docContent,
                                                       label: Label("(optional)",
                                                                    systemImage: "photo.on.rectangle.angled")
                                                        .vTop()
                                                        .hCenter())
        )
    }
    
    var shareButton: some View{
        Button(action: submitFeatureRequest ,label: {
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
            inputEmail
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
