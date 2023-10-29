//
//  TubeView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-12.
//

import SwiftUI

struct TubeVariables{
    var currentMagnification = 1.0
    var currentRotation = Angle.zero
    var location = CGPoint()
    
}

enum TubeInteraction{
    case IS_MOVEABLE
    case IS_STATIC
}


struct TubeView: View{
    @EnvironmentObject var tubeViewModel: TubeViewModel
    @GestureState private var pinchMagnification: CGFloat = 1.0
    @GestureState private var twistAngle: Angle = Angle.zero
    @GestureState private var fingerLocation: CGPoint? = nil
    @GestureState private var startLocation: CGPoint? = nil
    let tubeInteraction:TubeInteraction
    
    
    // MARK: - HELPER
    func calculateScale(size:CGSize) -> CGFloat{
        let a = sqrt(pow(size.width, 2) + pow(size.height, 2))
        let b = sqrt(pow(tubeViewModel.muff.width, 2) + pow(tubeViewModel.muff.height, 2))
        return (a/b)/2.0
    }
    
    func calculateOffset(size:CGSize) -> CGSize{
        return CGSize(width: size.width/2, height: size.height/2)
    }
    
    // MARK: - GESTRURES
    var simpleDragGesture: some Gesture {
        DragGesture()
        .onChanged { value in
            var newLocation = startLocation ?? tubeViewModel.posVar.location
            newLocation.x += value.translation.width
            newLocation.y += value.translation.height
            tubeViewModel.posVar.location = newLocation
        }.updating($startLocation) { (value, startLocation, transaction) in
            startLocation = startLocation ?? tubeViewModel.posVar.location
        }
    }
        
    var fingerDragGesture: some Gesture {
        DragGesture()
        .updating($fingerLocation) { (value, fingerLocation, transaction) in
            fingerLocation = value.location
        }
    }
    
    var rotationGesture: some Gesture{
        RotationGesture()
        .updating($twistAngle){ (value, twistAngle, transaction) in
            twistAngle = value
        }
        .onEnded { angle in
            tubeViewModel.posVar.currentRotation += angle
        }
    }
    
    var magnificationGesture: some Gesture{
        MagnificationGesture()
        .updating($pinchMagnification){ (value, pinchMagnification, transaction) in
            pinchMagnification = value
        }
        .onEnded{ scale in
            tubeViewModel.posVar.currentMagnification *= scale
        }
    }
    
    // MARK: - TUBE BASE
    var tubeBase: some View{
        Path { path in
            let ox = tubeViewModel.muff.pMin.x
            let oy = tubeViewModel.muff.pMin.y
            // LEN A LOWER
            path.move(to: CGPoint(x:tubeViewModel.tubeBase.bb.x - ox,y:tubeViewModel.tubeBase.bb.y - oy))
            path.addLine(to: CGPoint(x: tubeViewModel.tubeBase.p1.x - ox, y:tubeViewModel.tubeBase.p1.y - oy))
            // TUBE
            path.addArc(center: CGPoint(x:-ox,y:-oy),
                        radius: tubeViewModel.settingsVar.tube.radie,
                        startAngle: Angle(degrees:0),
                        endAngle: Angle(degrees:tubeViewModel.settingsVar.tube.grader),
                        clockwise: false)
            // LEN B UPPER
            path.move(to: CGPoint(x:tubeViewModel.tubeBase.p2.x - ox,y: tubeViewModel.tubeBase.p2.y - oy))
            path.addLine(to: CGPoint(x:tubeViewModel.tubeBase.pp3.x - ox, y: tubeViewModel.tubeBase.pp3.y - oy))
        }
        .tubeStroke(steel: tubeViewModel.settingsVar.tube.steel)
    }
    
    // MARK: - TUBE BASE DIAGONAL LINE TO CENTER
    var diagonalLine: some View{
        return Path { path in
            let ox = tubeViewModel.muff.pMin.x
            let oy = tubeViewModel.muff.pMin.y
            path.addArc(center: CGPoint(x:-ox,y:-oy),
                        radius: 10,
                        startAngle: Angle(degrees:0),
                        endAngle: Angle(degrees:360),
                        clockwise: true)
            path.move(to: CGPoint(x:-ox,y:-oy))
            path.addLine(to: tubeViewModel.tubeBase.centerOfTube)
            path.addArc(center: tubeViewModel.tubeBase.centerOfTube,
                        radius: 10,
                        startAngle: Angle(degrees:0),
                        endAngle: Angle(degrees:360),
                        clockwise: true)
        }
        .tubeDiagonalLine(width: 2.0)
    }
    
    // MARK: - FULL CIRCLE
    var fullCircle: some View{
        return Path { path in
            let ox = tubeViewModel.muff.pMin.x
            let oy = tubeViewModel.muff.pMin.y
            path.addArc(center: CGPoint(x:-ox,y:-oy),
                        radius: tubeViewModel.settingsVar.tube.radie,
                        startAngle: Angle(degrees:0),
                        endAngle: Angle(degrees:360),
                        clockwise: true)
        }
        .tubeDiagonalLine(width: 2.0)
    }
    
    // MARK: - TUBE CENTER LINE
    var tubeCenterLine: some View{
        Path { path in
            if tubeViewModel.tubeBase.b_xy_p_list.isEmpty { return }
            let ox = tubeViewModel.muff.pMin.x
            let oy = tubeViewModel.muff.pMin.y
            // LEN A LOWER
            path.move(to: CGPoint(x:tubeViewModel.tubeBase.b_xy_p_list[0].x - ox,
                                  y:tubeViewModel.tubeBase.b_xy_p_list[0].y - oy))
            for i in stride(from:1,to:tubeViewModel.tubeBase.b_xy_p_list.count,by:1){
                let p = tubeViewModel.tubeBase.b_xy_p_list[i]
                path.addLine(to: CGPoint(x:p.x - ox,y:p.y - oy))
            }
            
        }
        .tubeCenterLine(width: 2.0)
    }
    
    // MARK: - MUFF BOUNDINGBOX
    var boundingBox: some View{
        Path { path in
            // BOUNDING BOX
            let ox = tubeViewModel.muff.pMin.x
            let oy = tubeViewModel.muff.pMin.y
            path.move(to: CGPoint(x:tubeViewModel.muff.pMin.x - ox,y:tubeViewModel.muff.pMin.y - oy))
            path.addLine(to: CGPoint(x:tubeViewModel.muff.pMax.x - ox,y:tubeViewModel.muff.pMin.y - oy))
            path.addLine(to: CGPoint(x:tubeViewModel.muff.pMax.x - ox,y:tubeViewModel.muff.pMax.y - oy))
            path.addLine(to: CGPoint(x:tubeViewModel.muff.pMin.x - ox,y:tubeViewModel.muff.pMax.y - oy))
            path.closeSubpath()
        }
        .tubeCenterLine(width: 1.0)
    }
    
    // MARK: - MUFF
    var muff: some View{
        Path { path in
            if tubeViewModel.muff.emptyL1OrL2 { return }
            let ox = tubeViewModel.muff.pMin.x
            let oy = tubeViewModel.muff.pMin.y
            
            let startL1 = tubeViewModel.muff.l1[0]
            path.move(to: CGPoint(x:startL1.x - ox,y:startL1.y - oy))
            for i in stride(from:1,to:tubeViewModel.muff.l1.count,by:1){
                let p = tubeViewModel.muff.l1[i]
                path.addLine(to: CGPoint(x:p.x - ox,y:p.y - oy))
            }
            
            let startL2 = tubeViewModel.muff.l2[0]
            path.move(to: CGPoint(x:startL2.x - ox,y:startL2.y - oy))
            for i in stride(from:1,to:tubeViewModel.muff.l2.count,by:1){
                let p = tubeViewModel.muff.l2[i]
                path.addLine(to: CGPoint(x:p.x - ox,y:p.y - oy))
            }
        }
        .muffStroke()
    }
    
    // MARK: - MUFF MIDPOINT INNER AND OUTER
    var muffMidPoint: some View{
        Path { path in
            let ox = tubeViewModel.muff.pMin.x
            let oy = tubeViewModel.muff.pMin.y
            let inner = tubeViewModel.muff.midInnerPoint
            let outer = tubeViewModel.muff.midOuterPoint
            let mid = HalfLine(p: TPoint(x: inner.x - ox,y: inner.y - oy),
                               r: TPoint(x: outer.x - ox,y: outer.y - oy)).halfCgPoint
            path.addArc(center: mid,
                        radius: 5,
                        startAngle: Angle(degrees:0),
                        endAngle: Angle(degrees:360),
                        clockwise: true)
            path.addArc(center: CGPoint(x:inner.x - ox,y:inner.y - oy),
                        radius: 5,
                        startAngle: Angle(degrees:0),
                        endAngle: Angle(degrees:360),
                        clockwise: true)
            path.addArc(center: CGPoint(x:outer.x - ox,y:outer.y - oy),
                        radius: 5,
                        startAngle: Angle(degrees:0),
                        endAngle: Angle(degrees:360),
                        clockwise: true)
            path.move(to: CGPoint(x:inner.x - ox,y:inner.y - oy))
            path.addLine(to: CGPoint(x:outer.x - ox,y:outer.y - oy))
        }
        .muffMidPoint(width: 2.0)
    }
    
    // MARK: - CUT LINES
    var cutLines: some View{
        Path { path in
            if (tubeViewModel.muff.l1.count <= 1 ||
                tubeViewModel.muff.l2.count <= 1 ||
                tubeViewModel.muff.l1.count != tubeViewModel.muff.l1.count) { return }
            
            let ox = tubeViewModel.muff.pMin.x
            let oy = tubeViewModel.muff.pMin.y
            
            for i in stride(from:1,to:tubeViewModel.muff.l1.count-1,by:1){
                let startL1 = tubeViewModel.muff.l1[i]
                path.move(to: CGPoint(x:startL1.x - ox,y:startL1.y - oy))
                
                let p = tubeViewModel.muff.l2[i]
                path.addLine(to: CGPoint(x:p.x - ox,y:p.y - oy))
            }
        }
        .boxStroke()
    }
    
    // MARK: - CENTERLINES
    var centerLines: some View{
        Path { path in
            if tubeViewModel.muff.centerLines.count <= 1 { return }
            let maxIndex = tubeViewModel.muff.centerLines.count - 1
            let ox = tubeViewModel.muff.pMin.x
            let oy = tubeViewModel.muff.pMin.y
            
            let ll1 = tubeViewModel.muff.centerLines[0]
            let ll2 = tubeViewModel.muff.centerLines[maxIndex]
            
            let p0 = ll1.p1
            path.move(to: CGPoint(x:p0.x - ox,y:p0.y - oy))
            let p1 = ll1.p2
            path.addLine(to: CGPoint(x:p1.x - ox,y:p1.y - oy))
            let p2 = ll2.p2
            path.addLine(to: CGPoint(x:p2.x - ox,y:p2.y - oy))
            let p3 = ll2.p1
            path.addLine(to: CGPoint(x:p3.x - ox,y:p3.y - oy))
            path.addLine(to: CGPoint(x:p0.x - ox,y:p0.y - oy))
            
            
          
        }
        .tubeCenterLine(width: 2.0)
    }
    
    // MARK: - LABELS DEGREES
    var labelsDegrees: some View{
        ZStack{
            let ox = tubeViewModel.muff.pMin.x
            let oy = tubeViewModel.muff.pMin.y
            ForEach(tubeViewModel.muff.labels,id:\.self){ label in
                Text(label.text)
                    .rotation3DEffect(.degrees(180.0), axis: (x: 1, y: 0, z: 0))
                    .rotationEffect(Angle(degrees: label.rotation))
                    .foregroundColor(Color.white)
                    .position(x:label.pos.x - ox,y:label.pos.y - oy)
                    .padding()
            }
        }
    }
    
    // MARK: - LABELS LENGTH
    var labelsLength: some View{
        ZStack{
            let ox = tubeViewModel.muff.pMin.x
            let oy = tubeViewModel.muff.pMin.y
            ForEach(tubeViewModel.muffDetails.seg_list,id:\.self){ segment in
                Text(segment.innerLength)
                    .rotation3DEffect(.degrees(180.0), axis: (x: 1, y: 0, z: 0))
                    .rotationEffect(Angle(degrees: segment.rotation + 90.0))
                    .foregroundColor(Color.white)
                    .position(x:segment.pInner.x - ox,y:segment.pInner.y - oy)
                    .padding(.all,-12.0)
                Text(segment.outerLength)
                    .rotation3DEffect(.degrees(180.0), axis: (x: 1, y: 0, z: 0))
                    .rotationEffect(Angle(degrees: segment.rotation + 90.0))
                    .foregroundColor(Color.white)
                    .position(x:segment.pOuter.x - ox,y:segment.pOuter.y - oy)
                    .padding(.all,12)
            }
        }
    }
    
    // MARK: - HIT TEST
    var hitTest: some View{
        Color.clear
        .frame(width: tubeViewModel.muff.width,
               height: tubeViewModel.muff.height)
        .contentShape(Rectangle())
    }
    
    // MARK: - DRAW OPTION
    @ViewBuilder
    func getDrawOption(index:Int) -> some View{
        switch index{
        case 0: labelsDegrees
        case 1: labelsLength
        case 2: cutLines
        case 3: centerLines
        case 4: diagonalLine
        case 5: muffMidPoint
        case 6: boundingBox
        case 7: tubeCenterLine
        case 8: fullCircle
        default: EmptyView()
        }
    }
    
    
    
    var tubeMoveable:some View{
        GeometryReader{ reader in
            ZStack {
                hitTest
                tubeBase
                muff
                ForEach(DrawOption.indexOf(op: .LABELSDEGREES)..<DrawOption.indexOf(op: .FULLCIRCLE) + 1,id: \.self){ index in
                    if tubeViewModel.userDefaultSettingsVar.drawOptions[index]{
                        getDrawOption(index:index)
                    }
                }
            }
            .scaleEffect(tubeViewModel.posVar.currentMagnification * pinchMagnification * calculateScale(size: reader.size))
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            .rotationEffect(tubeViewModel.posVar.currentRotation + twistAngle + Angle(degrees: 180.0))
            .position(tubeViewModel.posVar.location)
            .offset(CGSizeMake(reader.size.width/2, reader.size.height/2))
            .simultaneousGesture(simpleDragGesture.simultaneously(with: fingerDragGesture))
            .simultaneousGesture(rotationGesture.simultaneously(with: magnificationGesture))
        }
    }
    
    var tubeStatic:some View{
        GeometryReader{ reader in
            ZStack {
                hitTest
                tubeBase
                muff
            }
            .scaleEffect(calculateScale(size: reader.size))
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            .rotationEffect(Angle(degrees: 180.0))
            .position(CGPoint())
            .offset(CGSizeMake(reader.size.width/2, reader.size.height/2))
        }
    }
    
    // MARK: - BODY
    var body: some View{
        switch tubeInteraction {
        case .IS_MOVEABLE:  tubeMoveable
        case .IS_STATIC:    tubeStatic
        }
    }
    
}
