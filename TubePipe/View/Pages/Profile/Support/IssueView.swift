//
//  IssueView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-10-10.
//

import SwiftUI

struct IssueView:View{
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @EnvironmentObject var globalLoadingPresentation: GlobalLoadingPresentation
    @State var docContent: DocumentContent = DocumentContent()
    @FocusState var focusField: Field?
    @State var collapseFooter:Bool = true
    @State var submitHasBeenMade:Bool = false
    let issueString =
        """
         If you`re having trouble in some part of the app you`ve come to the right place.
        Please use this form to tell us about the issue you`re experience.
         
         Please provide a detailed description of the issue, including:
         1. What you were doing when the problem occurred
         2. What you expect to happen
         3. What actually happen.
         4. Is this problem consistent or does it come and go.
        """
    let issueStringShort = "If you`re having trouble..."
    let thankReporter =
    """
    Thank you for taking the time to write a report and helping us make TubePipe better.
    The team will look in to it and we`re sorry for any inconvenience this may have caused.
    /Team TubePipe
    """
    
    var buttonIsDisabled:Bool{
        docContent.isNotAValidDocument||globalLoadingPresentation.isLoading
    }
    
    var issueHeader:some View{
        Text("Report")
        .font(.title)
        .bold()
        .foregroundColor(Color.black)
        .hLeading()
        .padding(.top)
    }
    
    
    var footerLabelToggle:some View{
        ZStack{
            if collapseFooter{
                issueFooterShort
            }
            else{
                issueFooterLong
            }
        }
        .onTapGesture {
            withAnimation{
                collapseFooter.toggle()
            }
        }
    }
    
    var issueFooterLong:some View{
        ScrollView{
            Text("\(issueString)")
            .listSectionFooter()
            .hLeading()
        }
        
    }
    
    var issueFooterShort:some View{
        Text(issueString)
        .listSectionFooter()
        .lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
        .hLeading()
    }
    
    var issueTopHeader:some View{
        VStack{
            issueHeader
            footerLabelToggle
        }
        .padding([.leading,.trailing])
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
        InputDocumentField(label: Text("Title:"),content:
                            TextField("",text:$docContent.title.max(MAX_TEXTFIELD_LEN),onCommit: {})
                                .preferedDocumentField()
                                .focused($focusField,equals: .DOCUMENT_TITLE)
                                .placeholder("issue",
                                             when: (focusField != .DOCUMENT_TITLE && docContent.title.isEmpty))
                                .lineLimit(1)
                                
        )
    }
    
    var inputDescription:some View{
        InputDocumentField(label: Text("Message:"),content:
            ZStack{
                TextField("",text:$docContent.message.max(MAX_TEXTFIELD_LEN*4),axis: .vertical)
                .preferedDocumentField()
                .lineLimit(nil)
                .focused($focusField,equals: .DOCUMENT_MESSAGE)
                .placeholder("description of issue",
                             when: (focusField != .DOCUMENT_MESSAGE) && (docContent.message.isEmpty))
                .vTop()
                .hLeading()
                Text("\(MAX_TEXTFIELD_LEN*4-docContent.message.count)")
                .font(.caption)
                .foregroundColor(Color.systemGray)
                .frame(width:33.0)
                .hTrailing()
                .vBottom()
            }
            .frame(height: 250.0)
        )
    }
    
    var inputEmail:some View{
        InputDocumentField(label: Text("Email:"),content:
                            TextField("",text:$docContent.email.max(MAX_TEXTFIELD_LEN),onCommit: {})
                                .preferedDocumentField()
                                .focused($focusField,equals: .DOCUMENT_EMAIL)
                                .placeholder(when: (focusField != .DOCUMENT_EMAIL && docContent.email.isEmpty)){
                                    optionalText
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
        .fullListWidthSeperator()
        .buttonStyle(BorderlessButtonStyle())
     }
    
    
    var shareButton: some View{
        Button(action: submitIssueReport ,label: {
            Text("Submit")
        })
        .disabled(buttonIsDisabled)
        .opacity(buttonIsDisabled ? 0.2 : 1.0)
        .foregroundColor(buttonIsDisabled ? .black :.systemBlue)
        .toolbarFontAndPadding()
        .bold()
    }
    
    var infoBody:some View{
        VStack(spacing:0){
            issueTopHeader
            List{
                inputTitle.listRowBackground(Color.lightText)
                inputDescription.listRowBackground(Color.lightText)
                inputEmail.listRowBackground(Color.lightText)
                //inputScreenshot
            }
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
        }
    }
    
    var body:some View{
        AppBackgroundStack(content: {
            infoBody
            //.onSubmit { submitIssueReport() }
            //.submitLabel(.send)
        },title:"Issue")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                shareButton
            }
        }
        .onTapGesture {
            endTextEditing()
        }
        .modifier(NavigationViewModifier(title: ""))
        .hiddenBackButtonWithCustomTitle("Profile")
        .alert("Report submitted",
               isPresented: $submitHasBeenMade,
               actions: { Button("Thank you!", role: .cancel){ clearDocument() } },
               message: { Text("\(thankReporter)") })
        
    }
    
    func clearDocument(){
        docContent.clearDocument()
        focusField = nil
    }
    
    func submitIssueReport(){
        docContent.trim()
        if buttonIsDisabled{ return }
        let issueId = docContent.documentId
        let storageId = docContent.storageId
        let email = docContent.enteredEmail
        let issue = IssueReport(issueId: issueId,
                                email: email,
                                title: docContent.title,
                                description: docContent.message,
                                date: Date(),
                                storageId: storageId)
        
        globalLoadingPresentation.startLoading()
        firestoreViewModel.submitNewIssueReport(issue,
                                                issueId: issueId,
                                                imgData: docContent.data){result in
            globalLoadingPresentation.stopLoading(isSuccess:result.isSuccess,
                                                  message: result.message,
                                                  showAnimationCircle: false)
            if result.isSuccess{ submitHasBeenMade.toggle() }
            
        }
        
    }
}
