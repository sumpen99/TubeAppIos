//
//  UserSettingsView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-10-26.
//

import SwiftUI

struct UserSettingsView:View{
    @EnvironmentObject var navViewModel: NavigationViewModel
    @EnvironmentObject var tubeViewModel: TubeViewModel
    @State private var toast: Toast? = nil
    let settingsOption:[SettingsOption] = SettingsOption.allCases
    
    var changesHasHappend:Bool{ tubeViewModel.settingsVar.hasChanges }
  
    var valuesCanBeUpdated:Bool{
        changesHasHappend && !tubeViewModel.muff.emptyL1OrL2
    }
        
    var settingsLabel:some View{
        Text("Default values")
        .font(.title)
        .bold()
        .hLeading()
    }
    
    var settingsFooter:some View{
        Text("Specify each value you would like the tube to have on startup.")
        .listSectionFooter()
        .font(.footnote)
        .hLeading()
    }
    
    var tube:some View{ TubeView(tubeInteraction: .IS_STATIC) }
    
    @ViewBuilder
    var overlayError:some View{
        if tubeViewModel.muff.emptyL1OrL2{
            ZStack{
                Text("Invalid tubevalues!")
                .font(.title)
                .bold()
                .foregroundColor(.red)
            }
            .vTop()
            .hLeading()
        }
    }
    
    var tubeWindow:some View{
        ZStack{
            tube
            overlayError
        }
        .padding()
        .padding()
        .hCenter()
        .frame(height: 150.0)
        .background{
            tubeViewModel.muff.emptyL1OrL2 ? Color.black.opacity(0.2) : Color.lightText
        }
    }
    
    var overlapSection:some View{
        Section{
            SliderSection(sliderValue: $tubeViewModel.settingsVar.tube.overlap,
                          minValue: 1,
                          maxValue: SLIDER_MAX_OVERLAP,
                          textEnding: "mm")
        } header: {
            Text("Overlap length").foregroundColor(Color.black)
        }
        
    }
    
    func settingsSection(_ item:SettingsOption) -> some View{
        return Section {
            switch item{
            case .DEGREES:
                SliderSection(sliderValue: $tubeViewModel.settingsVar.tube.grader,
                              minValue: 0,
                              maxValue: SLIDER_MAX_DEGREES,
                              textEnding: "°")
            case .DIMENSION:
                SliderSection(sliderValue: $tubeViewModel.settingsVar.tube.dimension,
                              minValue: 1,
                              maxValue:SLIDER_MAX_DIMENSION,
                              textEnding: "mm")
            case .SEGMENT:
                SliderSection(sliderValue: $tubeViewModel.settingsVar.tube.segment,
                              minValue: 0,
                              maxValue: SLIDER_MAX_SEGMENT,
                              textEnding: "st")
            case .STEEL:
                SliderSection(sliderValue: $tubeViewModel.settingsVar.tube.steel,
                              minValue: 1,
                              maxValue: SLIDER_MAX_DIMENSION,
                              textEnding: "mm")
            case .RADIUS:
                SliderSection(sliderValue: $tubeViewModel.settingsVar.tube.radie,
                              minValue: 1,
                              maxValue: SLIDER_MAX_RADIUS,
                              textEnding: "mm")
            case .LENA:
                SliderSection(sliderValue: $tubeViewModel.settingsVar.tube.lena,
                              minValue: 1,
                              maxValue: SLIDER_MAX_LENGTH,
                              textEnding: "mm")
            case .LENB:
                SliderSection(sliderValue: $tubeViewModel.settingsVar.tube.lenb,
                              minValue: 1,
                              maxValue: SLIDER_MAX_LENGTH,
                              textEnding: "mm")
            }
        } header: {
            Text(item.rawValue).foregroundColor(Color.black)
        }
    }
    
    var sections:some View{
        LazyVStack{
            ForEach(settingsOption,id:\.self){ op in
                settingsSection(op)
                Divider().overlay{ Color.tertiaryLabel }.padding([.leading,.trailing])
            }
            overlapSection
        }.background{
            Color.lightText
        }
    }
    
    var content:some View{
        VStack(spacing:0){
            settingsLabel.padding()
            tubeWindow.padding([.leading,.trailing])
            settingsFooter.padding([.leading,.trailing,.bottom])
            ScrollView{
                VStack(spacing:0){
                    sections.padding([.leading,.trailing])
                }
          
            }
        }
    }
    
    @ViewBuilder
    var leadingButton:some View{
        if changesHasHappend{
            Button(action: loadDefaultValues) {
                Text("Reset").foregroundColor(.systemRed).bold()
            }
            .toolbarFontAndPadding(.headline)
        }
        else{
            BackButton(title: "Profile",color: Color.accentColor)
            .toolbarFontAndPadding()
        }
    }
    
    var trailingButton:some View{
        Button(action: saveNewDefaultValues) {
            Text("Save").foregroundColor(.systemBlue).bold()
        }
        .toolbarFontAndPadding(.headline)
        .opacity(valuesCanBeUpdated ? 1.0 : 0.0)
        .disabled(!valuesCanBeUpdated)
    }
    
    var body:some View{
        AppBackgroundStack(content: {
            content
        },title:"Tube settings")
        .toastView(toast: $toast)
        .onAppear{ setUserDefaultValues() }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) { leadingButton }
            ToolbarItem(placement: .navigationBarTrailing) { trailingButton }
        }
        .onDisappear{ tubeViewModel.initFromCache() }
        .onTapGesture{ endTextEditing() }
        .modifier(NavigationViewModifier(title: ""))
        .navigationBarBackButtonHidden()
    }
    
    //MARK: LOAD TUBEVIEWMODEL
    func setUserDefaultValues(){
        tubeViewModel.settingsVar.stash()
        loadDefaultValues()
    }
    func resetBackToPreviousValues(){
        tubeViewModel.initFromCache()
    }
    func saveNewDefaultValues(){
        tubeViewModel.saveUserDefaultTubeValues()
        loadDefaultValues()
        toast = Toast(style: .success, message: "Saved")
    }
    func loadDefaultValues(){
        tubeViewModel.loadTubeDefaultValues(compareTubesMode: true)
        tubeViewModel.rebuild()
    }
}
