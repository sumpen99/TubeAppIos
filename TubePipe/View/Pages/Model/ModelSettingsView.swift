//
//  ModelSettingsView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-12.
//

import SwiftUI

struct ModelSettingsView:View{
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tubeViewModel: TubeViewModel
    @Binding var renderNewState:Bool
     
    var modelHeaderMenuList:  some View{
        ZStack{
            HStack{
                Text("Displayoption")
                .font(.headline)
                .frame(height: 33)
                Button("\(Image(systemName: BACK_BUTTON_PRIMARY))", action: closeView)
                .hTrailing()
            }
            .padding([.leading,.trailing,.top])
            
        }
        .frame(height:MENU_HEIGHT)
    }
    
    //MARK: - SWITCHES
    @ViewBuilder
    func modelSwitchSection(header:String,imageName:String,index:Int,clearConnectedIndexes:[Int]) -> some View{
        HStack{
            listDotWithImage(imageName)
            Text(header).font(.body).foregroundColor(.black)
            Spacer()
            Toggle(isOn: self.$tubeViewModel.userDefaultSettingsVar.drawOptions[index]){}
                .toggleStyle(CheckboxStyle(alignLabelLeft: true,labelIsOnColor:.black))
                .disabled(self.tubeViewModel.userDefaultSettingsVar.drawOptions[index])
                .onChange(of:self.tubeViewModel.userDefaultSettingsVar.drawOptions[index]){ isActive in
                    if isActive{
                        for idx in clearConnectedIndexes{
                            self.tubeViewModel.userDefaultSettingsVar.drawOptions[idx] = false
                        }
                        renderNewState.toggle()
                    }
                }
        }
        .hLeading()
        .padding()
    }
     
    @ViewBuilder
    func modelSwitchSectionBase(index:Int) -> some View{
        switch index{
        case DrawOption.indexOf(op: .DRAW_FILLED_MUFF):
            modelSwitchSection(header: "Filled Muff",
                               imageName: "circle.fill",
                               index: DrawOption.indexOf(op: .DRAW_FILLED_MUFF),
                               clearConnectedIndexes:[DrawOption.indexOf(op: .DRAW_LINED_MUFF),
                                                      DrawOption.indexOf(op: .DRAW_SEE_THROUGH_MUFF)])
        case DrawOption.indexOf(op: .DRAW_LINED_MUFF):
            modelSwitchSection(header: "Outlined Muff",
                               imageName: "circle.dashed",
                               index: DrawOption.indexOf(op: .DRAW_LINED_MUFF),
                               clearConnectedIndexes:[DrawOption.indexOf(op: .DRAW_FILLED_MUFF),
                                                      DrawOption.indexOf(op: .DRAW_SEE_THROUGH_MUFF)])
        case DrawOption.indexOf(op: .DRAW_SEE_THROUGH_MUFF):
            modelSwitchSection(header: "See Through Muff",
                               imageName: "circle",
                               index: DrawOption.indexOf(op: .DRAW_SEE_THROUGH_MUFF),
                               clearConnectedIndexes:[DrawOption.indexOf(op: .DRAW_LINED_MUFF),
                                                      DrawOption.indexOf(op: .DRAW_FILLED_MUFF)])
        case DrawOption.indexOf(op: .SHOW_WHOLE_MUFF):
            modelSwitchSection(header: "Whole Muff",
                               imageName: "oval.portrait.fill",
                               index: DrawOption.indexOf(op: .SHOW_WHOLE_MUFF),
                               clearConnectedIndexes:[DrawOption.indexOf(op: .SHOW_SPLIT_MUFF)])
        case DrawOption.indexOf(op: .SHOW_SPLIT_MUFF):
            modelSwitchSection(header: "Half Muff",
                               imageName: "oval.portrait.lefthalf.filled",
                               index: DrawOption.indexOf(op: .SHOW_SPLIT_MUFF),
                               clearConnectedIndexes:[DrawOption.indexOf(op: .SHOW_WHOLE_MUFF)])
        case DrawOption.indexOf(op: .FULL_SIZE_MUFF):
            modelSwitchSection(header: "Full length",
                               imageName: "ruler.fill",
                               index: DrawOption.indexOf(op: .FULL_SIZE_MUFF),
                               clearConnectedIndexes:[DrawOption.indexOf(op: .SCALED_SIZE_MUFF)])
        case DrawOption.indexOf(op: .SCALED_SIZE_MUFF):
            modelSwitchSection(header: "Scaled length",
                               imageName: "ruler",
                               index: DrawOption.indexOf(op: .SCALED_SIZE_MUFF),
                               clearConnectedIndexes:[DrawOption.indexOf(op: .FULL_SIZE_MUFF)])
        default: EmptyView()
        }
    }
    
    var sizeMuffSection: some View{
        Section( content:{
            ForEach(DrawOption.indexOf(op: .FULL_SIZE_MUFF)..<DrawOption.indexOf(op: .SHOW_WHOLE_MUFF),id: \.self){ index in
                modelSwitchSectionBase(index: index)
            }},
                 header: {Text("Size").leadingSectionHeader(color: Color.systemGray)}) {
        }
    }
    
    var showPartOfMuffSection: some View{
        Section(content:{
            ForEach(DrawOption.indexOf(op: .SHOW_WHOLE_MUFF)..<DrawOption.indexOf(op: .DRAW_FILLED_MUFF),id: \.self){ index in
                modelSwitchSectionBase(index: index)
            }},
            header: {Text("Show").leadingSectionHeader(color: Color.systemGray)}) {
        }
    }
    
    var drawMuffSection: some View{
        Section(content:{
            ForEach(DrawOption.indexOf(op: .DRAW_FILLED_MUFF)..<DrawOption.indexOf(op: .ALL_OPTIONS),id: \.self){ index in
                modelSwitchSectionBase(index: index)
            }},
            header: {Text("Draw").leadingSectionHeader(color: Color.systemGray)}) {
        }
    }
       
     var mainPage:some View{
         List{
             sizeMuffSection
             showPartOfMuffSection
             drawMuffSection
         }
         .padding(.bottom)
         .scrollContentBackground(.hidden)
     }
    
    //MARK: - BODY
    var body: some View{
        VStack(spacing:10){
            modelHeaderMenuList
            Divider()
            mainPage
        }
        .padding(.bottom)
        .modifier(HalfSheetModifier())
        .onDisappear(){
            if tubeViewModel.userDefaultSettingsVar.drawingHasChanged{
                tubeViewModel.saveUserDefaultDrawingValues()
            }
        }
    }
    
    //MARK: - HELPER
    func closeView(){
        dismiss()
    }
}
