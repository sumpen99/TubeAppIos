//
//  GradientViews.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-20.
//

import SwiftUI

var appButtonGradient: some View{
    Color.tertiarySystemFill
    
}

var appLabelGradient: some View{
    LinearGradient(
        gradient: .init(colors: [
            Color(hex: 0x343a40),
            Color(hex: 0x212529)]),
        startPoint: .leading,
        endPoint: .trailing)
}

var appLinearGradient: some View{
    Color.backgroundPrimary.edgesIgnoringSafeArea(.all)
}

var halfSheetBackgroundColor:some View{
    Color.lightText.edgesIgnoringSafeArea(.all)
}

struct HalfCircleGradient: View {
    let progress:CGFloat
    let addOpacity:Bool
    
    var body: some View {
        ZStack {
            //Circle().fill(Color.white).opacity(addOpacity ? 0.9 : 1.0).padding(-HALF_LINE_WIDTH)
            Circle()
                .trim(from: 0.0, to: 1.0)
                .stroke(style: StrokeStyle(lineWidth: LINE_WIDTH, lineCap: .round, lineJoin: .round))
                .opacity(0.3)
                .foregroundColor(Color.backgroundPrimary)
                .rotationEffect(.degrees(90.0))
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: LINE_WIDTH, lineCap: .round, lineJoin: .round))
                .fill(AngularGradient(gradient: Gradient(stops: [
                    .init(color: Color(hex: 0xadb5bd), location: 0.39000002),
                    .init(color: Color(hex: 0x6c757d), location: 0.48000002),
                    .init(color: Color(hex: 0x495057), location: 0.5999999),
                    .init(color: Color(hex: 0x343a40), location: 0.7199998),
                    .init(color: Color(hex: 0x212529), location: 0.8099997)]), center: .center))
                .rotationEffect(.degrees(90.0))
        }
    }
 
}

/*import CoreGraphics


struct HexagonParameters {
    struct Segment {
        let line: CGPoint
        let curve: CGPoint
        let control: CGPoint
    }


    static let adjustment: CGFloat = 0.085


    static let segments = [
        Segment(
            line:    CGPoint(x: 0.60, y: 0.05),
            curve:   CGPoint(x: 0.40, y: 0.05),
            control: CGPoint(x: 0.50, y: 0.00)
        ),
        Segment(
            line:    CGPoint(x: 0.05, y: 0.20 + adjustment),
            curve:   CGPoint(x: 0.00, y: 0.30 + adjustment),
            control: CGPoint(x: 0.00, y: 0.25 + adjustment)
        ),
        Segment(
            line:    CGPoint(x: 0.00, y: 0.70 - adjustment),
            curve:   CGPoint(x: 0.05, y: 0.80 - adjustment),
            control: CGPoint(x: 0.00, y: 0.75 - adjustment)
        ),
        Segment(
            line:    CGPoint(x: 0.40, y: 0.95),
            curve:   CGPoint(x: 0.60, y: 0.95),
            control: CGPoint(x: 0.50, y: 1.00)
        ),
        Segment(
            line:    CGPoint(x: 0.95, y: 0.80 - adjustment),
            curve:   CGPoint(x: 1.00, y: 0.70 - adjustment),
            control: CGPoint(x: 1.00, y: 0.75 - adjustment)
        ),
        Segment(
            line:    CGPoint(x: 1.00, y: 0.30 + adjustment),
            curve:   CGPoint(x: 0.95, y: 0.20 + adjustment),
            control: CGPoint(x: 1.00, y: 0.25 + adjustment)
        )
    ]
}

struct BadgeBackground: View {
    
    var scaleFactor:CGFloat = 1.0
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                var width: CGFloat = min(geometry.size.width, geometry.size.height) * scaleFactor
                let height = width
                let xScale: CGFloat = 0.832
                let xOffset = (width * (1.0 - xScale)) / 2.0
                width *= xScale
                path.move(
                    to: CGPoint(
                        x: width * 0.95 + xOffset,
                        y: height * (0.20 + HexagonParameters.adjustment)
                    )
                )


                HexagonParameters.segments.forEach { segment in
                    path.addLine(
                        to: CGPoint(
                            x: width * segment.line.x + xOffset,
                            y: height * segment.line.y
                        )
                    )


                    path.addQuadCurve(
                        to: CGPoint(
                            x: width * segment.curve.x + xOffset,
                            y: height * segment.curve.y
                        ),
                        control: CGPoint(
                            x: width * segment.control.x + xOffset,
                            y: height * segment.control.y
                        )
                    )
                }
            }
            .fill(.linearGradient(
                Gradient(colors: [Self.gradientStart, Self.gradientEnd]),
                startPoint: UnitPoint(x: 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5, y: 0.6)
            ))
        }
        .aspectRatio(1, contentMode: .fit)
    }
    static let gradientStart = Color(red: 239.0 / 255, green: 120.0 / 255, blue: 221.0 / 255)
    static let gradientEnd = Color(red: 239.0 / 255, green: 172.0 / 255, blue: 120.0 / 255)
}
*/
