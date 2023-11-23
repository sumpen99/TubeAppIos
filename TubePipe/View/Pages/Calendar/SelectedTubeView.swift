//
//  SelectedTubeView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-07.
//

import SwiftUI

struct SelectedTubeView: View{
    let tubeModel:TubeModel
    let labelBackButton:String
    let loadViewModelWithTubeModel: (TubeModel) -> Void
    let deleteTubeModel: (TubeModel) -> Void
    @Environment(\.dismiss) private var dismiss
    @State var isDeleteTube:Bool = false
    
    
    var loadButton:some View{
        Button(action: { loadViewModelWithTubeModel(tubeModel);closeView() }){
            Text("Load")
        }
        .buttonStyle(ButtonStyleFillListRow(lblColor: Color.systemBlue))
    }
    
    var deleteButton:some View{
        Button(action: removeTubeAlert ){
            Text("Delete")
        }
        .buttonStyle(ButtonStyleFillListRow(lblColor: Color.systemRed))
    }
    
    var buttons:some View{
        return Section(content:{
            LazyVStack(spacing:10){
                loadButton
                Divider()
                deleteButton
            }},
            header: {Text("Action:").listSectionHeader()}) {
        }
    }
    
    var muffSummary: some View{
        return TubeModelSummary(tubeModel: tubeModel)
    }
    
    var messageSummary: some View{
        return Section(content:{
            LazyVStack(spacing:10){
                SubHeaderSubHeaderLeadingView(subMain: Text("Message:"),
                                              subSecond: Text(tubeModel.message ?? ""))
                SubHeaderSubHeaderLeadingView(subMain: Text("Saved:"),
                                              subSecond:Text(tubeModel.date?.formattedStringWithTime() ?? "00:00:00"))
            }},
            header: {Text("Details:").listSectionHeader()}) {
            
        }
    }
    
    func attachedPhoto(_ uiImage:UIImage) -> some View{
        return Section(content:{
                Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()},
            header: {Text("Attached photo")}) {
            
        }
    }
    
    var data:some View{
        List{
            if let data = tubeModel.image?.data,
               let uiImage = UIImage(data: data){
               attachedPhoto(uiImage).listRowBackground(Color.white)
            }
            messageSummary.listRowBackground(Color.white)
            muffSummary.listRowBackground(Color.white)
            buttons
        }
        .listStyle(.automatic)
        .scrollContentBackground(.hidden)
    }
    
    var mainPage:some View{
        VStack(spacing:0){
            TopMenu(title: tubeModel.date?.formattedString() ?? "Saved tube", actionCloseButton: closeView)
            data
        }
    }
    
    var body:some View{
        AppBackgroundSheetStack(content: {
            mainPage
        })
        .alert(isPresented: $isDeleteTube, content: {
            onAlertWithOkAction(actionPrimary: {
                deleteTubeModel(tubeModel)
                closeView()
           })
        })
        
    }
    
    func removeTubeAlert(){
        ALERT_TITLE = "Remove tube"
        ALERT_MESSAGE = "Do you want to remove tube saved on \(tubeModel.date?.formattedStringWithTime() ?? "00:00:00")"
        isDeleteTube.toggle()
    }
    
    func closeView(){
        dismiss()
    }
}
