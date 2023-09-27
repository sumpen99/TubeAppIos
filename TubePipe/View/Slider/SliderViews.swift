//
//  SliderViews.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI

struct SliderSection:View{
    @EnvironmentObject var tubeViewModel: TubeViewModel
    @Binding var sliderValue:CGFloat
    let minValue:CGFloat
    let maxValue:CGFloat
    let textEnding:String
    @State var textfieldValue:String
    var isNotAlignmentSection:Bool = true
    
    @ViewBuilder
    var leftButton: some View{
        TapAndHoldButton(
            tapAction: { _ in
                let val = max(sliderValue - 1.0,minValue)
                sliderValue = val
        },holdAction: {
            let val = max(sliderValue - 10.0,minValue)
            sliderValue = val },
            imageName: "minus")
        .hLeading()
    }
    
    @ViewBuilder
    var rightButton: some View{
        TapAndHoldButton(
            tapAction: { _ in
            let val = min(sliderValue + 1.0,maxValue)
            sliderValue = val
        },holdAction: {
            let val = min(sliderValue + 10.0,maxValue)
            sliderValue = val },
            imageName: "plus")
        .hTrailing()
    }
    
    @ViewBuilder
    var sliderButtons: some View{
        let binding = Binding<String>(get: { self.textfieldValue },
                                      set: {
                     guard let num = Int($0) else {
                        self.sliderValue = CGFloat(0)
                        return
                    }
                    self.sliderValue = min(maxValue,max(minValue,CGFloat(num)))
                 })
        HStack{
            leftButton
            TextField("\(textfieldValue)\(textEnding)",text: binding).preferedTubeSettingsField()
            rightButton
        }
    }
    
    func alignmentSliderButtons() -> some View{
        return HStack{
            leftButton
            Text("\(sliderValue.toStringWith(precision:"%.2f"))").settingsText().hCenter()
            rightButton
        }
    }
    
    var primarySliderSection:some View{
        VStack(spacing:10){
            sliderButtons
        }
        .onChange(of: sliderValue){ newValue in
            textfieldValue = "\(Int(newValue))"
            tubeViewModel.rebuild()
            tubeViewModel.settingsVar.redraw.toggle()
        }
        .padding([.leading,.trailing])
    }
    
    var alignemntSliderSection: some View{
        VStack(spacing:10){
            alignmentSliderButtons()
        }
        .onChange(of: sliderValue){ newValue in
            tubeViewModel.settingsVar.alreadyCalculated = true
            tubeViewModel.calculate()
            tubeViewModel.settingsVar.redraw.toggle()
        }
        .padding([.leading,.trailing])
    }
    
    var body: some View{
        if isNotAlignmentSection{
            primarySliderSection
        }
        else{
            alignemntSliderSection
        }
        
    }
}
