//
//  AxisButton.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-22.
//

import SwiftUI

struct AxisButton:View{
    @EnvironmentObject var tubeSceneViewModel: TubeSceneViewModel
    let axis:AxisDirection
     
    var label:some View{
        Text(AxisDirection.textByAxis(axis))
        .font(.largeTitle)
        .foregroundColor(Color(uiColor:AxisDirection.colorByAxis(axis)))
    }
    
    var minusButton:some View{
        TapAndHoldButton(
            tapAction: { _ in tubeSceneViewModel.updatePosition(onAxis:axis,with:-10.0) },
            holdAction: { tubeSceneViewModel.updatePosition(onAxis:axis,with:-100.0) },
            imageName: "plus",
            color: Color(uiColor:AxisDirection.colorByAxis(axis)))
    }
    
    var plusButton:some View{
        TapAndHoldButton(
            tapAction: { _ in tubeSceneViewModel.updatePosition(onAxis:axis,with:10.0) },
            holdAction: { tubeSceneViewModel.updatePosition(onAxis:axis,with:100.0) },
            imageName: "minus",
            color: Color(uiColor:AxisDirection.colorByAxis(axis)))
    }
    
    @ViewBuilder
    var buttonRow:some View{
        VStack{
            minusButton.padding()
            plusButton.padding()
        }
        
    }
    
    var body:some View{
        buttonRow
    }
}
