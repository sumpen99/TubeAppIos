//
//  SaveDocumentView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI

struct SaveDocumentView:View{
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var managedObjectContext
    @EnvironmentObject var tubeViewModel: TubeViewModel
    @State var docContent:DocumentContent = DocumentContent()
    @State private var toast: Toast? = nil
      
    var saveButton: some View{
        Button(action:saveNewTube,label: {
            Text("Save").hCenter()
        })
        .buttonStyle(ButtonStyleDocument())
        .padding()
    }
    
    var mainContent:some View{
        VStack(spacing:10){
            ScrollView{
                BaseTubeTextField(docContent: $docContent).padding(.top)
                ImagePickerSwiftUi(docContent: $docContent,
                                   label:Label("Attach photo",systemImage: "photo.on.rectangle.angled"))
            }
            saveButton
        }
        .padding([.leading,.trailing])
    }
    
    var body: some View{
        VStack(spacing:0){
            TopMenu(title: "Save document", actionCloseButton: closeView)
            Section {
                mainContent
            } header: {
                Text(Date().formattedString()).sectionTextSecondary(color:.tertiaryLabel).padding(.leading)
            }
        }
        .toastView(toast: $toast)
        .halfSheetBackgroundStyle()
    }
    
    //MARK: - BUTTON FUNCTIONS
    func closeView(){
        dismiss()
    }
    
    func saveNewTube(){
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

