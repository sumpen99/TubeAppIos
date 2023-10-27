//
//  UserSettingsView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-10-26.
//

import SwiftUI

struct UserSettingsView:View{
    @EnvironmentObject var tubeViewModel: TubeViewModel
    let settingsOption:[SettingsOption] = SettingsOption.allCases
    
    var changesHasHappend:Bool{ tubeViewModel.settingsVar.hasChanges }
    
    var settingsFooter:some View{
        Text("Specify default values for tube on start up.")
        .listSectionFooter()
        .hCenter()
        .padding(.top)
    }
    
    var tube:some View{
        TubeView()
        .disabled(true)
        .padding()
        .border(Color.darkGray,width: 3.0)
        .padding()
        .hCenter()
        .frame(height: 250.0)
    }
    
    var overlapSection:some View{
        Section{
            SliderSection(sliderValue: $tubeViewModel.settingsVar.overlap,
                          minValue: 1.0,
                          maxValue: SLIDER_MAX_OVERLAP,
                          textEnding: "mm",
                          textfieldValue: "\(Int(tubeViewModel.settingsVar.overlap))")
        } header: {
            Text("Overlap").foregroundColor(Color.systemGray)
        }
        
    }
    
    func settingsSection(_ item:SettingsOption) -> some View{
        return Section {
            switch item{
            case .DEGREES:
                SliderSection(sliderValue: $tubeViewModel.settingsVar.grader,
                              minValue: 0.0,
                              maxValue: SLIDER_MAX_DEGREES,
                              textEnding: "°",
                              textfieldValue: "\(Int(tubeViewModel.settingsVar.grader))")
            case .DIMENSION:
                SliderSection(sliderValue: $tubeViewModel.settingsVar.dimension,
                              minValue: 1.0,
                              maxValue:SLIDER_MAX_DIMENSION,
                              textEnding: "mm",
                              textfieldValue: "\(Int(tubeViewModel.settingsVar.dimension))")
            case .SEGMENT:
                SliderSection(sliderValue: $tubeViewModel.settingsVar.segment,
                              minValue: 0.0,
                              maxValue: SLIDER_MAX_SEGMENT,
                              textEnding: "st",
                              textfieldValue: "\(Int(tubeViewModel.settingsVar.segment))")
            case .STEEL:
                SliderSection(sliderValue: $tubeViewModel.settingsVar.steel,
                              minValue: 1.0,
                              maxValue: SLIDER_MAX_DIMENSION,
                              textEnding: "mm",
                              textfieldValue: "\(Int(tubeViewModel.settingsVar.steel))")
            case .RADIUS:
                SliderSection(sliderValue: $tubeViewModel.settingsVar.radie,
                              minValue: 1.0,
                              maxValue: SLIDER_MAX_RADIUS,
                              textEnding: "mm",
                              textfieldValue: "\(Int(tubeViewModel.settingsVar.radie))")
            case .LENA:
                SliderSection(sliderValue: $tubeViewModel.settingsVar.lena,
                              minValue: 1.0,
                              maxValue: SLIDER_MAX_LENGTH,
                              textEnding: "mm",
                              textfieldValue: "\(Int(tubeViewModel.settingsVar.lena))")
            case .LENB:
                SliderSection(sliderValue: $tubeViewModel.settingsVar.lenb,
                              minValue: 1.0,
                              maxValue: SLIDER_MAX_LENGTH,
                              textEnding: "mm",
                              textfieldValue: "\(Int(tubeViewModel.settingsVar.lenb))")
            }
        } header: {
            Text(item.rawValue).foregroundColor(Color.systemGray)
        }
    }
    
    var sections:some View{
        ScrollView{
            LazyVStack{
                ForEach(settingsOption,id:\.self){ op in
                    settingsSection(op)
                    Divider().overlay{ Color.white }.padding([.leading,.trailing])
                }
                overlapSection
                Divider().overlay{ Color.white }.padding([.leading,.trailing])
                clearSpaceAtBottom
            }
        }
    }
    
    var content:some View{
        VStack{
            settingsFooter
            tube
            sections
        }
    }
    
    var body:some View{
        AppBackgroundStack(content: {
            content
        })
        .onAppear{
            tubeViewModel.settingsVar.stash()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { }) {
                    Text("Reset")
                }
                .padding(.trailing)
                .opacity(changesHasHappend ? 1.0 : 0.0)
                .disabled(!changesHasHappend)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { }) {
                    Text("Save")
                }
                .opacity(changesHasHappend ? 1.0 : 0.0)
                .disabled(!changesHasHappend)
            }
        }
        .onTapGesture{ endTextEditing() }
        .modifier(NavigationViewModifier(title: ""))
        .hiddenBackButtonWithCustomTitle("Profile")
    }
}
