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
    @State var docContent:DocumentContent = DocumentContent()
    @State private var toast: Toast? = nil
    
    var buttonIsDisabled:Bool{
        docContent.isSaving||docContent.message.isEmpty
    }
  
    var saveButton: some View{
        Button(action:saveNewTube,label: {
            Text("Save")
        })
        .disabled(buttonIsDisabled)
        .opacity(buttonIsDisabled ? 0.2 : 1.0)
        .foregroundColor(buttonIsDisabled ? .black : .systemBlue)
        .font(.title2)
        .bold()
        .hTrailing()
        .vTop()
        .padding([.trailing])
    }
    
    var body: some View{
        VStack(spacing:0){
            TopMenu(title: "Save document", actionCloseButton: closeView)
            Section {
                BaseTubeTextField(docContent: $docContent,placeHolder: "Add a comment or title to save file on device")
                .padding()
                .vTop()
            } header: {
                Text(Date().formattedString()).sectionTextSecondary(color:.black).padding(.leading)
            } footer:{
                
            }
        }
        .onSubmit { saveNewTube() }
        .submitLabel(.send)
        .toastView(toast: $toast)
        .halfSheetBackgroundStyle()
    }
    
    //MARK: - BUTTON FUNCTIONS
    func closeView(){
        dismiss()
    }
    
    func saveNewTube(){
        if buttonIsDisabled { return }
        docContent.isSaving = true
        let managedObjectContext = PersistenceController.shared.container.viewContext
        let model = TubeModel(context:managedObjectContext)
        tubeViewModel.buildModelFromCurrentValues(model)
        docContent.trim()
        model.message = docContent.message
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

