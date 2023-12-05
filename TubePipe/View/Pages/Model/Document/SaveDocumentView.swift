//
//  SaveDocumentView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI

struct SaveDocumentView:View{
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tubeViewModel: TubeViewModel
    @FocusState var focusField: Field?
    @State var docContent:DocumentContent = DocumentContent()
    @State private var toast: Toast? = nil
    @State var invalidTube:Bool = false
    
    var buttonIsDisabled:Bool{
        docContent.isSaving||docContent.message.isEmpty
    }
  
    var clearButton: some View{
        Button(action:{ docContent.message = ""},label: {
            Image(systemName: "xmark.square.fill")
        })
        .foregroundColor(buttonIsDisabled ? Color.tertiaryLabel : .red)
        .font(.title2)
        .bold()
    }
    
    var saveButton: some View{
        Button(action:saveNewTube,label: {
            Text("Save")
            .font(.headline)
            .padding(.horizontal,10)
            .padding(.vertical,3)
            .overlay(
                Rectangle()
                    .stroke(buttonIsDisabled ? Color.tertiaryLabel : Color.systemBlue, lineWidth: 1)
            )
            
        })
        .foregroundColor(buttonIsDisabled ? Color.tertiaryLabel : .systemBlue)
    }
    
    var body: some View{
        VStack(spacing:0){
            TopMenu(title: "Save document", actionCloseButton: closeView)
            Section {
                BaseTubeTextField(docContent: $docContent,
                                  focusField: _focusField,
                                  placeHolder: "Add a comment or title to save file on device")
                .padding()
                .vTop()
            } header: {
                HStack{
                    Text(Date().formattedString()).sectionTextSecondary(color:.black).hLeading().padding(.leading)
                    clearButton.padding(.trailing)
                    saveButton.padding(.trailing)
                 }
            }
         }
        .alert("Tube error!", isPresented: $invalidTube){
            Button("OK", role: .cancel,action: { closeView() })
        } message: {
            Text("Current Tubevalues are invalid. Their`s no point in storing those. Sorry for any inconvenience. We`re closing this view now.")
        }
        .onAppear{
            closeIfInvalidTube()
        }
        .toastView(toast: $toast)
        .halfSheetBackgroundStyle()
        .onTapGesture {
            endTextEditing()
        }
    }
    
    //MARK: - BUTTON FUNCTIONS
    func closeView(){
        dismiss()
    }
    
    func closeIfInvalidTube(){
        if tubeViewModel.muff.emptyL1OrL2{
            invalidTube.toggle()
        }
    }
    
    func saveNewTube(){
        docContent.trim()
        if buttonIsDisabled{ return }
        docContent.isSaving = true
        let managedObjectContext = PersistenceController.shared.container.viewContext
        let model = TubeModel(context:managedObjectContext)
        tubeViewModel.buildModelFromCurrentValues(model,
                                                  message: docContent.message)
        if docContent.data != nil{
            let image = TubeImage(context:managedObjectContext)
            image.id = model.id
            image.data = docContent.data
            model.image = image
        }
        do{
            try PersistenceController.saveContext()
            closeAfterToast(isSuccess: true,msg:"Document saved!",toast: &toast,action: closeView)
        }
        catch{
            closeAfterToast(isSuccess: false,msg:"Operation failed!",toast: &toast,action: closeView)
        }
        
    }
    
}

