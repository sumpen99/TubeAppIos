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
        docContent.message.isEmpty
    }
    
    var toggleFullFooterButton:some View{
        Button(collapseFooter ? "\(Image(systemName: "chevron.right"))" : "\(Image(systemName: "chevron.down"))", action: {
            withAnimation{
                collapseFooter.toggle()
            }
        })
        .buttonStyle(ButtonStyleList(color: Color.systemBlue))
    }
    
    var issueHeader:some View{
        Text("Report an issue")
        .font(.title)
        .bold()
        .foregroundColor(Color.GHOSTWHITE)
        .hLeading()
    }
    
    var sectionFooter: some View{
        Section(content: {
            if !collapseFooter{
                LazyVStack {
                    issueFooterLong
                }
            }
       }, header: { footerLabelToggle })
    }
    
    var footerLabelToggle:some View{
        HStack{
            issueFooterShort.opacity(collapseFooter ? 1.0 : 0.0)
            toggleFullFooterButton
        }
    }
    
    var issueFooterLong:some View{
        ScrollView{
            VStack{
                Text("\(issueString)")
                .listSectionFooter()
                .hLeading()
            
            }
        }
        
    }
    
    var issueFooterShort:some View{
        Text(issueStringShort)
        .listSectionFooter()
        .hLeading()
    }
    
    var issueTopHeader:some View{
        VStack{
            issueHeader
            sectionFooter
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
                            .hTrailing()
                            .vBottom()
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
        Button(action: submitIssueReport,label: {
            Text("Submit").hCenter()
        })
        .disabled(buttonIsDisabled)
        .buttonStyle(ButtonStyleDisabledable(lblColor:Color.blue,backgroundColor: Color.GHOSTWHITE))
        .padding()
    }
    
    var inputBody:some View {
        VStack{
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
            issueTopHeader
            List{
                inputBody
            }
            .listStyle(.insetGrouped)
            shareButton
        }
        
    }
    
    var body:some View{
        AppBackgroundStack(content: {
            infoBody
        })
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
        let issueId = docContent.documentId
        let storageId = docContent.storageId
        let email = docContent.enteredEmail
        let issue = IssueReport(issueId: issueId,
                                email: email,
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
