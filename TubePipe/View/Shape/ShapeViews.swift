//
//  ShapeViews.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-20.
//

import SwiftUI

struct RoundedCorners: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct Triangle:Shape{
    
    func path(in rect:CGRect) -> Path{
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        return path
    }
}
