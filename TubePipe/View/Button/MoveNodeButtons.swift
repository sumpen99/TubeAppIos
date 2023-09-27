//
//  MoveNodeButtons.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-22.
//

import SwiftUI

struct MoveNodeButtons:View{
   
    var body:some View{
        HStack{
            AxisButton(axis: .AXIS_X)
            AxisButton(axis: .AXIS_Y)
            AxisButton(axis: .AXIS_Z)
        }
        /*.background(
           RoundedRectangle(cornerRadius: 8).fill(Color.white)
        )*/
        /*.overlay{
            RoundedRectangle(cornerRadius: 8).stroke(lineWidth: 2.0).foregroundColor(.systemGray)
        }*/
    }
}
