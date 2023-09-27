//
//  PathExtensions.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI

extension Path{
    
    func tubeDiagonalLine(width:CGFloat) -> some View{
        self.stroke(Color.red, style: StrokeStyle(lineWidth: width,lineJoin: .round))
    }
    
    func tubeCenterLine(width:CGFloat) -> some View{
        self.stroke(Color.red, style: StrokeStyle(lineWidth: width,lineJoin: .round))
    }
    
    func tubeStroke(steel:CGFloat) -> some View{
        self.stroke(Color.black, style: StrokeStyle(lineWidth: steel,lineJoin: .round))
    }
    
    func boxStroke() -> some View{
        self.stroke(Color.black, style: StrokeStyle(lineWidth: 1,lineJoin: .round))
    }
    
    func muffStroke() -> some View{
        self.stroke(Color.black, style: StrokeStyle(lineWidth: 5,lineJoin: .round))
    }
    
    func muffMidPoint(width:CGFloat) -> some View{
        self.stroke(Color.red, style: StrokeStyle(lineWidth: width,lineJoin: .round))
    }
}

