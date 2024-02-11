//
//  ScannerFrame.swift
//  TubePipe
//
//  Created by fredrik sundström on 2024-02-11.
//

import SwiftUI

struct ScannerFrame:View {
    let size:CGSize
    var body: some View {
        ZStack{
            Path { path in
                path.addPath(
                    cornersPath
                )
            }
            .stroke(Color.systemBlue, lineWidth:2)
        }
        .vCenter()
        .hCenter()
    }
    
    var cornersPath:Path {
        let centerWidth = size.width/2.0
        let centerHeight = size.height/2.0
        var path = Path()
        let left = centerWidth-25.0
        let right = centerWidth+25.0
        let top = centerHeight-25.0
        let bottom = centerHeight+25.0
        let width = right - left
        let radius = width / 20.0 / 2.0
        let cornerLength = width / 10.0

        path.move(to: CGPoint(x: left, y: top + radius))
        path.addArc(
            center: CGPoint(x: left + radius, y: top + radius),
            radius: radius,
            startAngle: Angle(degrees: 180.0),
            endAngle: Angle(degrees: 270.0),
            clockwise: false
        )

        path.move(to: CGPoint(x: left + radius, y: top))
        path.addLine(to: CGPoint(x: left + radius + cornerLength, y: top))

        path.move(to: CGPoint(x: left, y: top + radius))
        path.addLine(to: CGPoint(x: left, y: top + radius + cornerLength))

        path.move(to: CGPoint(x: right - radius, y: top))
        path.addArc(
            center: CGPoint(x: right - radius, y: top + radius),
            radius: radius,
            startAngle: Angle(degrees: 270.0),
            endAngle: Angle(degrees: 360.0),
            clockwise: false
        )

        path.move(to: CGPoint(x: right - radius, y: top))
        path.addLine(to: CGPoint(x: right - radius - cornerLength, y: top))

        path.move(to: CGPoint(x: right, y: top + radius))
        path.addLine(to: CGPoint(x: right, y: top + radius + cornerLength))

        path.move(to: CGPoint(x: left + radius, y: bottom))
        path.addArc(
            center: CGPoint(x: left + radius, y: bottom - radius),
            radius: radius,
            startAngle: Angle(degrees: 90.0),
            endAngle: Angle(degrees: 180.0),
            clockwise: false
        )
        
        path.move(to: CGPoint(x: left + radius, y: bottom))
        path.addLine(to: CGPoint(x: left + radius + cornerLength, y: bottom))

        path.move(to: CGPoint(x: left, y: bottom - radius))
        path.addLine(to: CGPoint(x: left, y: bottom - radius - cornerLength))

        path.move(to: CGPoint(x: right, y: bottom - radius))
        path.addArc(
            center: CGPoint(x: right - radius, y: bottom - radius),
            radius: radius,
            startAngle: Angle(degrees: 0.0),
            endAngle: Angle(degrees: 90.0),
            clockwise: false
        )
        
        path.move(to: CGPoint(x: right - radius, y: bottom))
        path.addLine(to: CGPoint(x: right - radius - cornerLength, y: bottom))

        path.move(to: CGPoint(x: right, y: bottom - radius))
        path.addLine(to: CGPoint(x: right, y: bottom - radius - cornerLength))

        return path
    }
}
