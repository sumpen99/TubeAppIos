//
//  IssueView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-10-10.
//

import SwiftUI

struct IssueView:View{
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
        (docContent.title.isEmpty||docContent.message.isEmpty)
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
                                .placeholder("(required field)",when: focusField != .DOCUMENT_TITLE)
        )
        .fieldFirstResponder{
            focusField = .DOCUMENT_TITLE
        }
       
    }
    
    var inputDescription:some View{
        InputDocumentField(label: Text("Description").vTop(),content:
                            HStack{
                            TextField("",text:$docContent.message.max(MAX_TEXTFIELD_LEN*4),axis: .vertical)
                                .preferedDocumentField()
                                .focused($focusField,equals: .DOCUMENT_MESSAGE)
                                .placeholder("(required field)",
                                             when: (focusField != .DOCUMENT_MESSAGE) && (docContent.message.isEmpty)).vTop()
                            Text("\(MAX_TEXTFIELD_LEN*4-docContent.message.count)").font(.caption).foregroundColor(Color.systemGray).hTrailing().frame(width:33.0).vBottom()}
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
            inputDescription
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
        NavigationView{
            AppBackgroundStack(content: {
                infoBody
            })
            .modifier(NavigationViewModifier(title: ""))
        }
        .hiddenBackButtonWithCustomTitle("Profile")
        .confirmationDialog("Report submitted",
                            isPresented: $submitHasBeenMade,
                            titleVisibility: .visible){
            Button("Thank you!", role: .cancel){}
        } message: {
            Text("\(thankReporter)")
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

