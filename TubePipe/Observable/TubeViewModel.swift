//
//  TubeViewModel.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-13.
//

import SwiftUI

struct TubePositionVariables{
    var currentMagnification = 1.0
    var currentRotation = Angle.zero
    var location = CGPoint()
}

class TubeViewModel: ObservableObject{
    @Published var settingsVar:SettingsVar = SettingsVar()
    @Published var userDefaultSettingsVar:UserDefaultSettingsVar = UserDefaultSettingsVar()
    @Published var posVar = TubePositionVariables()
    var tubeBase = TubeBase()
    var muffDetails = MuffDetails()
    var muff = Muff()
    var drawable:Bool{ userDefaultSettingsVar.drawOptions.count > 0}
    var muffDiff: CGFloat { settingsVar.tube.center }
    var useAutoAlign:Bool{
        userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .AUTO_ALIGN)]||settingsVar.forceAutoAlign
    }
    
    init(){
        if(loadUserDefaultValues()){
            calculate()
        }
    }
    
    func rebuild(){
        if useAutoAlign{
            settingsVar.resetCalculationMode()
        }
        else{
            settingsVar.tube.alreadyCalculated = true
        }
        calculate()
    }
    
    func calculate(){
        clearLists()
        drawCenterCircle()
        setTubeBaseBottomCenter()
        getDefaultBbox()
        let offsetFromCenter = calcDiagonal()
        
        if shouldAbort(offsetFromCenter: offsetFromCenter){
            return
            
        }
   
        if useAutoAlign{ calculateAutoAlign(offsetFromCenter:offsetFromCenter) }
        
        else{ calculateUserAlign() }
        
   }
    
    func calculateAutoAlign(offsetFromCenter:CGFloat){
        if offsetFromCenter > 0.0 && !settingsVar.tube.alreadyCalculated{
            alignTubeToCenter(offsetFromCenter: offsetFromCenter)
            calculate()
        }
        else {
            if !drawTube(){ return }
            getSegInOut()
            getTotalLenOfMuff()
            drawLabels()
            alignCenter()
        }
    }
    
    func calculateUserAlign(){
        if !drawTube(){ return }
        getSegInOut()
        getTotalLenOfMuff()
        drawLabels()
        alignCenter()
    }
    
    func shouldAbort(offsetFromCenter:CGFloat) -> Bool{
        return  settingsVar.tube.radie <= 0 ||
                (settingsVar.tube.grader <= 0 && settingsVar.tube.segment != 0) ||
                (settingsVar.tube.steel <= 0 || settingsVar.tube.steel >= settingsVar.tube.dimension) ||
                offsetFromCenter.isNaN
    }
    
    // MARK: - DO STEP 1
    func clearLists(){
        tubeBase = TubeBase()
        muffDetails = MuffDetails()
        muff = Muff()
    }
    
    // MARK: - DO STEP 2
    func drawCenterCircle(){
        let addHundred = userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .ADD_ONE_HUNDRED)] ? settingsVar.tube.overlap : 0.0
        
        let lena = settingsVar.tube.lena + addHundred
        let lenb = settingsVar.tube.lenb + addHundred
        
        let r = CGFloat(90.0 - settingsVar.tube.grader)
        let r1 = r.degToRad()
        let r2 = settingsVar.tube.grader.degToRad()
        
        let x1 = settingsVar.tube.radie
        let y1 = 0.0
        
        let x2 = settingsVar.tube.radie * sin(r1)
        let y2 = settingsVar.tube.radie * cos(r1)
        
        let x3 = lenb * sin(-r2) + x2
        let y3 = lenb * cos(-r2) + y2
        
        let by = -lena
        
        tubeBase.set(b:TPoint(x:x1, y: by),
                     p1:TPoint(x:x1,y: y1),
                     p2:TPoint(x:x2,y: y2),
                     p3:TPoint(x:x3,y: y3),
                     r1:r1)
        
        if userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .ADD_ONE_HUNDRED)]{
            let xx3 = settingsVar.tube.lenb * sin(-r2) + x2
            let yy3 = settingsVar.tube.lenb * cos(-r2) + y2
            let bb = TPoint(x:x1, y: -settingsVar.tube.lena)
            let pp3 = TPoint(x:xx3,y: yy3)
            tubeBase.setOptionalAddHundred(bb: bb, pp3: pp3)
        }
        else{
            tubeBase.setOptionalAddHundred(bb: TPoint(x:x1, y: by), pp3: TPoint(x:x3,y: y3))
        }
        
        tubeBase.setModelSteelPoints(getPointsSteel())
       
    }
    
    // MARK: - DO STEP 3
    func setTubeBaseBottomCenter(){
        let b_r = settingsVar.tube.grader / 2.0
        let b_r1 = CGFloat(90.0 - b_r).degToRad()
        let r = settingsVar.tube.radie - muffDiff
        let b_c_x = r * sin(b_r1)
        let b_c_y = r * cos(b_r1)
        tubeBase.b_c = TPoint(x:b_c_x,y:b_c_y)
    }
    
    // MARK: - DO STEP 4
    func calcDiagonal() -> CGFloat{
        let b_r = CGFloat(settingsVar.tube.grader / 2.0)
        let b_r2 = CGFloat(90.0).degToRad()
        let b_r3 = b_r.degToRad()
        
        let lenA = Line.calcLengthOfLine(p1: TPoint(x:0.0,y:0.0), p2: tubeBase.b_c)
        
        let off_r = (lenA * cos(b_r3))
     
        tubeBase.off_r = (settingsVar.tube.radie <= settingsVar.tube.center) ? off_r : -off_r
        
        let b_x1 = (settingsVar.tube.radie + tubeBase.off_r) * sin(b_r2) + tubeBase.b_c.x
        let b_y1 = (settingsVar.tube.radie + tubeBase.off_r) * cos(b_r2) + tubeBase.b_c.y
        
        let b_x2 = (settingsVar.tube.radie + tubeBase.off_r) * sin(tubeBase.r1) + tubeBase.b_c.x
        let b_y2 = (settingsVar.tube.radie + tubeBase.off_r) * cos(tubeBase.r1) + tubeBase.b_c.y
        
        let p1 = TPoint(x:b_x1,y:b_y1)
        let p2 = TPoint(x:b_x2,y:b_y2)
    
        var points:[TPoint] = []
        
        if userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .KEEP_DEGREES)]{
            points = getPoints()
        }
        else{
            points = getPointsDiff()
        }
        
        buildBXYList(points: points,p1:p1,p2:p2)
        tubeBase.l1 = HalfLine(p: TPoint(x:tubeBase.p3.x,y:tubeBase.p3.y), r: TPoint(x:b_x2,y:b_y2))
        tubeBase.l2 = HalfLine(p: TPoint(x:tubeBase.b.x,y:tubeBase.b.y), r: TPoint(x:b_x1,y:b_y1))
        tubeBase.l1?.extendLine(len: 1000.0)
        tubeBase.l2?.extendLine(len: 1000.0)
        return getOffsetFromMiddle(points:points,p1:p1,p2:p2)
        
    }
    
    func buildBXYList(points:[TPoint],p1:TPoint,p2:TPoint){
        tubeBase.b_xy_p_list.removeAll()
        tubeBase.b_xy_p_list.append(tubeBase.b)
        tubeBase.b_xy_p_list.append(p1)
        for p in points{
            tubeBase.b_xy_p_list.append(p)
        }
        tubeBase.b_xy_p_list.append(p2)
        tubeBase.b_xy_p_list.append(tubeBase.p3)
    }
    
    // MARK: - DO STEP 4:1
    func alignTubeToCenter(offsetFromCenter:CGFloat){
        if settingsVar.first == 0.0 {
            settingsVar.first = offsetFromCenter
            settingsVar.tube.center += (settingsVar.tube.grader <= 180) ? 1 : -1
        }
        else {
            settingsVar.tube.alreadyCalculated = true
            let div = settingsVar.first-offsetFromCenter
            settingsVar.first /= div
            settingsVar.tube.center = settingsVar.tube.grader > 180 ? -settingsVar.first : settingsVar.first
         }
    }
    
    // MARK: - DO STEP 5
    func drawTube() -> Bool{
        if settingsVar.tube.segment == 0 { return drawTubeSegZero() }
        else{ return drawTubeSegments() }
    }
    
    func drawTubeSegZero() -> Bool{
        if settingsVar.tube.grader > 180 { return false}
        let r = CGFloat(90.0 - (settingsVar.tube.grader/2.0))
        let r1 = r.degToRad()
        var b_x2: CGFloat
        var b_y2: CGFloat
        guard let l1 = tubeBase.l1,
              let l2 = tubeBase.l2 else { return false}
        
        let p = l1.intersect(other: l2)
     
        if p != nil{
            b_x2 = p?.x ?? 0.0
            b_y2 = p?.y ?? 0.0
        }
        else{
            b_x2 = (settingsVar.tube.radie+tubeBase.off_r) * sin(r1) + tubeBase.b_c.x
            b_y2 = (settingsVar.tube.radie+tubeBase.off_r) * cos(r1) + tubeBase.b_c.y
        }
        
        let p1 = TPoint(x:tubeBase.b.x,y:tubeBase.b.y)
        let p2 = TPoint(x:b_x2,y:b_y2)
        let p3 = TPoint(x:tubeBase.p3.x,y:tubeBase.p3.y)
        let n = getMuff(c_line: [p1,p2,p3])
        guard let l1 = n.l1,let l2 = n.l2 else { return false}
        muff.setL1L2(l1: l1, l2: l2)
        return true
    }
    
    func drawTubeSegments() -> Bool{
        let n = getMuff(c_line: tubeBase.b_xy_p_list)
        guard let l1 = n.l1,let l2 = n.l2 else { return false}
        muff.setL1L2(l1: l1, l2: l2)
        return true
    }
    
    func getMuff(c_line:[TPoint]) -> (l1:[CGPoint]?,l2:[CGPoint]?){
        let n = HalfLine.offsetLineSegments(points: c_line, offset: settingsVar.tube.dimension/2.0)
        if Line.checkForLineIntersection(inputSegments: [n.l1,n.l2]){
            return (l1:nil,l2:nil)
        }
        if checkForAngleOfError(l1: n.l1){
            return (l1:nil,l2:nil)
        }
        muff.setPoints(c_line)
        getBbox(n1:n.l1,n2:n.l2)
        return n
    
    }
    
    func checkForAngleOfError(l1:[CGPoint]) -> Bool{
        if l1.count < 2 { return true }
        let i = 2
        let p0 = l1[i-2]
        let p00 = l1[i-1]
        let f1 = HalfLine(p: TPoint(x:p0.x,y:p0.y), r: TPoint(x:p00.x,y:p00.y))
        if f1.angle < 1.0{ return true } // LEN A
        
        let j = l1.count - 1
        let p1 = l1[j-1]
        let p11 = l1[j]
        
        let h1 = HalfLine(p: TPoint(x:p1.x,y:p1.y), r: TPoint(x:p11.x,y:p11.y))
        if (h1.angle.isNaN || h1.angle.isInfinite) { return true }
        let dl = abs(settingsVar.tube.grader - h1.angle)
        if (0.0 <= dl) && (dl < 1.0){ return true }
        return false
    }
    
    // MARK: - DO STEP 6
    func getSegInOut(){
        if !muff.equalSizeL1L2 { return }
        var lastSegments:[(lf1:HalfLine,lh1:HalfLine,lf2:HalfLine,lh2:HalfLine)] = []
        for i in stride(from:2,to:muff.l1.count,by:1){
            let p0 = muff.l1[i-2]
            let p1 = muff.l2[i-2]
            
            let p00 = muff.l1[i-1]
            let p11 = muff.l2[i-1]
            
            let p000 = muff.l1[i]
            let p111 = muff.l2[i]
            
            var f1 = HalfLine(p: TPoint(x:p0.x,y:p0.y), r: TPoint(x:p00.x,y:p00.y))
            var f2 = HalfLine(p: TPoint(x:p1.x,y:p1.y), r: TPoint(x:p11.x,y:p11.y))
            
            var h1 = HalfLine(p: TPoint(x:p00.x,y:p00.y), r: TPoint(x:p000.x,y:p000.y))
            var h2 = HalfLine(p: TPoint(x:p11.x,y:p11.y), r: TPoint(x:p111.x,y:p111.y))
            
            h1.angleBetweenLines(l2: f1)
            f1.angleBetweenLines(l2: h1)
            
            h2.angleBetweenLines(l2: f2)
            f2.angleBetweenLines(l2: h2)
            
            if i == 2{
                if settingsVar.tube.segment == 0{
                    let p1Inner = f1.halfCgPoint
                    let p1Outer = f2.halfCgPoint
                    let p2Inner = h1.halfCgPoint
                    let p2Outer = h2.halfCgPoint
                    let s1 = Segment(pInner:p1Inner,
                                     pOuter:p1Outer,
                                     inner:f1.length,
                                     outer:f2.length,
                                     angle1:0.0,
                                     angle2:f2.angle_angle,
                                     rotation: f1.angle,
                                     seg_type:SegType.LENA,
                                     index:0)
                    let s2 = Segment(pInner:p2Inner,
                                     pOuter:p2Outer,
                                     inner:h1.length,
                                     outer:h2.length,
                                     angle1:0.0,
                                     angle2:h2.angle_angle,
                                     rotation: h1.angle,
                                     seg_type:SegType.LENB,
                                     index:1)
                    muffDetails.seg_list.append(s1)
                    muffDetails.seg_list.append(s2)
                }
                else{
                    let p1Inner = f1.halfCgPoint
                    let p1Outer = f2.halfCgPoint
                    let s1 = Segment(pInner:p1Inner,
                                     pOuter:p1Outer,
                                     inner:f1.length,
                                     outer:f2.length,
                                     angle1:0.0,
                                     angle2:f2.angle_angle,
                                     rotation: f1.angle,
                                     seg_type:SegType.LENA,
                                     index:0)
                    muffDetails.seg_list.append(s1)
                    lastSegments.append((lf1:f1,lh1:h1,lf2:f2,lh2:h2))
                }
            }
            else if i == (muff.l1.count - 1){
                let l = lastSegments[i-3]
                let p1Inner = l.lh1.halfCgPoint
                let p1Outer = l.lh2.halfCgPoint
                let p2Inner = h1.halfCgPoint
                let p2Outer = h2.halfCgPoint
                let s1 = Segment(pInner:p1Inner,
                                 pOuter:p1Outer,
                                 inner:l.lh1.length,
                                 outer:l.lh2.length,
                                 angle1:l.lh1.angle_angle,
                                 angle2:h1.angle_angle,
                                 rotation: l.lh1.angle,
                                 seg_type:SegType.SEG1,
                                 index:muffDetails.seg_list.count)
                let s2 = Segment(pInner:p2Inner,
                                 pOuter:p2Outer,
                                 inner:h1.length,
                                 outer:h2.length,
                                 angle1:0.0,
                                 angle2:h2.angle_angle,
                                 rotation: h1.angle,
                                 seg_type:SegType.LENB,
                                 index:muffDetails.seg_list.count+1)
                muffDetails.seg_list.append(s1)
                muffDetails.seg_list.append(s2)
            }
            else{
                let segType:SegType = i == 3 ? SegType.SEG1 : SegType.SEG2
                let l = lastSegments[i-3]
                let p1Inner = l.lh1.halfCgPoint
                let p1Outer = l.lh2.halfCgPoint
                lastSegments.append((lf1:f1,lh1:h1,lf2:f2,lh2:h2))
                let s1 = Segment(pInner:p1Inner,
                                 pOuter:p1Outer,
                                 inner:l.lh1.length,
                                 outer:l.lh2.length,
                                 angle1:l.lh1.angle_angle,
                                 angle2:h1.angle_angle,
                                 rotation: l.lh1.angle,
                                 seg_type:segType,
                                 index:muffDetails.seg_list.count)
                muffDetails.seg_list.append(s1)
            }
            
        }
    }
    
    func getTotalLenOfMuff(){
        muffDetails.dim = settingsVar.tube.dimension
        muffDetails.segments = Int(settingsVar.tube.segment)
        muffDetails.calcTotLen()
    }
    
    // MARK: - DO STEP 7
    func drawLabels(){
        if (muff.l2.count <= 1) || (!muff.equalSizeL1L2) { return }
        if self.settingsVar.tube.segment == 0{
            let lbl = CGFloat(self.settingsVar.tube.grader/2).toStringWith(precision: "%.2f")
            let rotation:CGFloat = 0.0
            let pos:CGPoint = muff.l2[1]
            muff.addLabel(DimensionLabel(text: lbl, pos: pos, rotation: rotation))
        }
        else if muffDetails.seg_list.count == muff.l1.count - 1{
            let nextLastIndex = muff.l1.count - 2
            let p1 = TPoint(x:muff.l1[1].x,y:muff.l1[1].y)
            let p2 = TPoint(x:muff.l2[1].x,y:muff.l2[1].y)
            let p3 = TPoint(x:muff.l1[nextLastIndex].x,y:muff.l1[nextLastIndex].y)
            let p4 = TPoint(x:muff.l2[nextLastIndex].x,y:muff.l2[nextLastIndex].y)
            var l1 = HalfLine(p: p1, r: p2)
            var l2 = HalfLine(p: p3, r: p4)
            l1.extendLine(len: 1000.0)
            l2.extendLine(len: 1000.0)
            guard let p = l1.intersect(other: l2) else{
                return
            }
            let cx = p.x
            let cy = p.y
            
            let ang1 = CGFloat(muffDetails.first_degree / 2.0).roundWith(precision: .HUNDREDTHS)
            let ang2 = CGFloat(muffDetails.cut_degree / 2.0).roundWith(precision: .HUNDREDTHS)
            
            for i in stride(from: 1, to: muff.l1.count - 1, by: 1){
                var lbl: String
                var rotation:CGFloat
                var pos:CGPoint
                
                let p:CGPoint = muff.l1[i]
                let pp:CGPoint = muff.l2[i]
                
                let l1 = HalfLine(p: TPoint(x:cx,y:cy), r: TPoint(x:p.x,y:p.y))
                
                if i == 1 || i == muff.l1.count-2{
                    var ll1 = i == 1 ? l1.offset(t: -10) : l1.offset(t: 10)
                    ll1.extendLine(len: -(ll1.length/2.0))
                    
                    lbl = ang1.toStringWith(precision: "%.2f")
                    rotation = ll1.angle - 90.0
                    pos = CGPoint(x:ll1.half.x,y:ll1.half.y)
                }
                else{
                    lbl = ang2.toStringWith(precision: "%.2f")
                    rotation = 0.0
                    pos = CGPoint(x:muff.l2[i].x,y:muff.l2[i].y)
                }
                rotation = 0.0
                pos = CGPoint(x:muff.l2[i].x,y:muff.l2[i].y)
                muff.centerLines.append(CenterLine(p1: CGPoint(x:cx,y:cy), p2: CGPoint(x:pp.x,y:pp.y)))
                muff.addLabel(DimensionLabel(text: lbl+"°", pos: pos, rotation: rotation))
           }
        }
    }
    
    // MARK: - DO STEP 8
    func alignCenter(){
        let r = CGFloat(90.0 - settingsVar.tube.grader/2.0)
        let r1 = r.degToRad()
        
        let x2 = settingsVar.tube.radie * sin(r1) - muff.pMin.x
        let y2 = settingsVar.tube.radie * cos(r1) - muff.pMin.y
        tubeBase.centerOfTube = CGPoint(x:x2,y:y2)
       
        if (settingsVar.tube.segment <= 0) { return }
        
        if (Int(settingsVar.tube.segment) % 2) == 0 { getEvenMiddleSegmentPoint() }
        else { getUnEvenMiddleSegmentPoint() }
    }
    
    func getEvenMiddleSegmentPoint(){
        let index = (Int(settingsVar.tube.segment) / 2) + 1
        if !muff.equalSizeL1L2 || index >= muff.l1.count { return }
        
        let ox = muff.pMin.x
        let oy = muff.pMin.y
        let p1 = muff.l1[index]
        let p2 = muff.l2[index]
        let pC = tubeBase.centerOfTube
        muff.midInnerPoint = p1
        muff.midOuterPoint = p2
  
        muff.lenInner = Line.calcLengthOfLine(p1: pC, p2: CGPoint(x: p1.x - ox, y: p1.y - oy))
        muff.lenOuter = Line.calcLengthOfLine(p1: pC, p2: CGPoint(x: p2.x - ox, y: p2.y - oy))
        
    }
    
    func getUnEvenMiddleSegmentPoint(){
        let index1 = ((Int(settingsVar.tube.segment) - 1) / 2) + 1
        let index2 = index1 + 1
        if !muff.equalSizeL1L2 || ((index1 >= muff.l1.count) || (index2 >= muff.l1.count)) { return }
        
        let ox = muff.pMin.x
        let oy = muff.pMin.y
        
        let p1l1 = muff.l1[index1]
        let p2l1 = muff.l1[index2]
        let p1l2 = muff.l2[index1]
        let p2l2 = muff.l2[index2]
        
        let l1 = HalfLine(p: TPoint(x:p1l1.x,y:p1l1.y), r: TPoint(x:p2l1.x,y:p2l1.y))
        let l2 = HalfLine(p: TPoint(x:p1l2.x,y:p1l2.y), r: TPoint(x:p2l2.x,y:p2l2.y))
        
        let p1 = CGPoint(x:l1.half.x,y:l1.half.y)
        let p2 = CGPoint(x:l2.half.x,y:l2.half.y)
        
        let pC = tubeBase.centerOfTube
        muff.midInnerPoint = p1
        muff.midOuterPoint = p2
        
        muff.lenInner = Line.calcLengthOfLine(p1: pC, p2: CGPoint(x: p1.x - ox, y: p1.y - oy))
        muff.lenOuter = Line.calcLengthOfLine(p1: pC, p2: CGPoint(x: p2.x - ox, y: p2.y - oy))
        
    }
    
    // MARK: - HELPER
    func getPoints() -> [TPoint]{
        if settingsVar.tube.segment == 0 {
            self.muffDetails.setDegree(first: settingsVar.tube.grader/2.0, cut: settingsVar.tube.grader/2.0)
            return []
        }
        var points:[TPoint] = []
        let segments = settingsVar.tube.segment
        let cuts:CGFloat = CGFloat(segments + 1)
        let p_cnt:Int = Int(segments) - 1
        let cut_degree:CGFloat = settingsVar.tube.grader / cuts
        self.muffDetails.setDegree(first: cut_degree, cut: cut_degree)
        
        let first_degree:CGFloat = (settingsVar.tube.grader - ((CGFloat(segments - 2)) * cut_degree)) / 2.0
    
        let fp:CGFloat = first_degree
        let c:CGFloat = settingsVar.tube.radie + tubeBase.off_r
        var A:CGFloat = fp
        var B:CGFloat = 90.0 - cut_degree
        var C:CGFloat = 180.0 - A - B
        
        A = A.degToRad()
        B = B.degToRad()
        C = C.degToRad()
  
        //let a = c * sin(A)/sin(C)
        let b = c * sin(B)/sin(C)
        let r2 = b
        for i in (0..<p_cnt){
            if i == 0{
                let r = CGFloat(90.0 - fp).degToRad()
                let x = r2 * sin(r) + tubeBase.b_c.x
                let y = r2 * cos(r) + tubeBase.b_c.y
                points.append(TPoint(x:x,y:y))
            }
            else if i == p_cnt - 1{
                let r = CGFloat(90.0 - (settingsVar.tube.grader - fp)).degToRad()
                let x = r2 * sin(r) + tubeBase.b_c.x
                let y = r2 * cos(r) + tubeBase.b_c.y
                points.append(TPoint(x:x,y:y))
            }
            else{
                let r = CGFloat(90.0 - (fp + (cut_degree*CGFloat(i)))).degToRad()
                let x = r2 * sin(r) + tubeBase.b_c.x
                let y = r2 * cos(r) + tubeBase.b_c.y
                points.append(TPoint(x:x,y:y))
            }
        }
        
        
        return points
    }
    
    func getPointsDiff() -> [TPoint]{
        if settingsVar.tube.segment == 0{
            self.muffDetails.setDegree(first: settingsVar.tube.grader, cut: settingsVar.tube.grader)
            return []
        }
        
        var points:[TPoint] = []
        let divider = CGFloat(settingsVar.tube.segment > 0 ? settingsVar.tube.segment : 1)
        let value = settingsVar.tube.grader / divider
        let p_cnt = Int(settingsVar.tube.segment) - 1
        self.muffDetails.setDegree(first: value/2.0, cut: value)
        
        for i in (0..<p_cnt){
            let r = CGFloat(90.0-(value*CGFloat(1+i))).degToRad()
            let x = (settingsVar.tube.radie+tubeBase.off_r) * sin(r) + tubeBase.b_c.x
            let y = (settingsVar.tube.radie+tubeBase.off_r) * cos(r) + tubeBase.b_c.y
            points.append(TPoint(x:x,y:y))
        }
        return points
    }
    
    func getPointsSteel() -> [TPoint]{
        var points:[TPoint] = []
        let segments = STEEL_SEGMENTS
        let cuts:CGFloat = CGFloat(segments + 1)
        let p_cnt:Int = segments - 1
        let cut_degree:CGFloat = settingsVar.tube.grader / cuts
        let first_degree:CGFloat = (settingsVar.tube.grader - ((CGFloat(segments - 2)) * cut_degree)) / 2.0
        let fp:CGFloat = first_degree
        let c:CGFloat = settingsVar.tube.radie
        var A:CGFloat = fp
        var B:CGFloat = 90.0 - cut_degree
        var C:CGFloat = 180.0 - A - B
        
        A = A.degToRad()
        B = B.degToRad()
        C = C.degToRad()
  
        let b = c * sin(B)/sin(C)
        let r2 = b
        points.append(tubeBase.bb)
        points.append(tubeBase.p1)
        for i in (0..<p_cnt){
            if i == 0{
                let r = CGFloat(90.0 - fp).degToRad()
                let x = r2 * sin(r) + tubeBase.centerOfTube.x
                let y = r2 * cos(r) + tubeBase.centerOfTube.y
                points.append(TPoint(x:x,y:y))
            }
            else if i == p_cnt - 1{
                let r = CGFloat(90.0 - (settingsVar.tube.grader - fp)).degToRad()
                let x = r2 * sin(r) + tubeBase.centerOfTube.x
                let y = r2 * cos(r) + tubeBase.centerOfTube.y
                points.append(TPoint(x:x,y:y))
            }
            else{
                let r = CGFloat(90.0 - (fp + (cut_degree*CGFloat(i)))).degToRad()
                let x = r2 * sin(r) + tubeBase.centerOfTube.x
                let y = r2 * cos(r) + tubeBase.centerOfTube.y
                points.append(TPoint(x:x,y:y))
            }
        }
        points.append(tubeBase.p2)
        points.append(tubeBase.pp3)
        return points
    }
    
    func getTubeCenterPoint() -> TPoint{
        let b_r = settingsVar.tube.grader / 2.0
        let b_r1 = CGFloat(90.0 - b_r).degToRad()
        let r = settingsVar.tube.radie
        let b_c_x = r * sin(b_r1)
        let b_c_y = r * cos(b_r1)
        return TPoint(x:b_c_x,y:b_c_y)
    }
    
    func getOffsetFromMiddle(points:[TPoint],p1:TPoint,p2:TPoint) -> CGFloat{
        if settingsVar.tube.segment == 0 { return 0.0}
        if settingsVar.tube.segment == 1{
            let l = HalfLine(p: p1, r: p2)
            return Line.calcLengthOfLine(p1: l.half, p2: getTubeCenterPoint())
        }
        else {
            if Int(settingsVar.tube.segment) % 2 == 0{
                let index:Int = Int(points.count/2)
                let p1 = points[index]
                return Line.calcLengthOfLine(p1: p1, p2: getTubeCenterPoint())
            }
            else{
                let index2:Int = points.count/2
                let index1 = index2-1
                let p1 = points[index1]
                let p2 = points[index2]
                let l = HalfLine(p: p1, r: p2)
                return Line.calcLengthOfLine(p1: l.half, p2: getTubeCenterPoint())
            }
        }
    }
    
    func getBbox(n1:[CGPoint],n2:[CGPoint]){
        var x_min = 0.0
        var y_min = 0.0
        var x_max = 0.0
        var y_max = 0.0
        
        for (l0,l1) in zip(n1, n2){
            let x0 = l0.x
            let y0 = l0.y
            let x1 = l1.x
            let y1 = l1.y
            
            
            x_min = getMin(a:x0,b:x1,c:x_min)
            x_max = getMax(a:x0,b:x1,c:x_max)
            
            y_min = getMin(a:y0,b:y1,c:y_min)
            y_max = getMax(a:y0,b:y1,c:y_max)
        }
        muff.setMinMax(m_in:TPoint(x:x_min,y:y_min),m_ax:TPoint(x:x_max,y:y_max))
    }
    
    func getDefaultBbox(){
        let b_r_x = tubeBase.b.x + settingsVar.tube.dimension/2.0
        let t_l_y = tubeBase.b.y - settingsVar.tube.dimension/2.0
        let t_l_x = b_r_x * -1
        let b_r_y = t_l_y * -1
        muff.setMinMax(m_in:TPoint(x:t_l_x,y:t_l_y),m_ax:TPoint(x:b_r_x,y:b_r_y))
     }
    
   
    func getMin(a:CGFloat,b:CGFloat,c:CGFloat) -> CGFloat{
        let aa = a.isNaN ? 0.0 : a
        let bb = b.isNaN ? 0.0 : b
        let cc = c.isNaN ? 0.0 : c
        let m_in = min(aa,bb)
        return min(m_in,cc)
    }
    
    func getMax(a:CGFloat,b:CGFloat,c:CGFloat) -> CGFloat{
        let aa = a.isNaN ? 0.0 : a
        let bb = b.isNaN ? 0.0 : b
        let cc = c.isNaN ? 0.0 : c
        let m_ax = max(aa,bb)
        return max(m_ax,cc)
    }
    
}

extension TubeViewModel{
    
    func pointsWithAddedCircle(renderSizePart:UInt16) -> [TPoint]{
        if muff.points.count < 3 { return [] }
        switch renderSizePart{
        case RenderOption.indexOf(op: .SCALED_SIZE_MUFF): return scaledListOfPoints()
        case RenderOption.indexOf(op: .FULL_SIZE_MUFF): fallthrough
        default: return fullListOfPoints()
        }
        
    }
    
    func steelPotentiallyScaled(renderSizePart:UInt16) -> [TPoint]{
        switch renderSizePart{
        case RenderOption.indexOf(op: .SCALED_SIZE_MUFF): return tubeBase.scaledPathToModel()
        case RenderOption.indexOf(op: .FULL_SIZE_MUFF): fallthrough
        default: return tubeBase.pathToModel
        }
        
    }
    
    func fullListOfPoints() -> [TPoint]{
        var pointsList:[TPoint] = []
        let maxCount = muff.points.count-1
        for (i,p) in muff.points.enumerated(){
            if i == 1{
                let lastPoint = muff.points[i-1]
                let p2 = HalfLine(p: p, r: lastPoint)
                pointsList.append(p2.pointOnLine(n:settingsVar.tube.radie)) // top of screen
            }
            else if i == maxCount{
                let lastPoint = muff.points[i-1]
                let p2 = HalfLine(p: lastPoint, r: p)
                pointsList.append(p2.pointOnLine(n:settingsVar.tube.radie)) // bottom of screen
            }
            pointsList.append(p)
        }
        return pointsList
    }
    
    func scaledListOfPoints() -> [TPoint]{
        tubeBase.resetScaled()
        var pointsList:[TPoint] = []
        let maxCount = muff.points.count-1
        let firstPoint:TPoint = muff.points[0]
        let lastPoint:TPoint = muff.points[maxCount-1]
        for (i,p) in muff.points.enumerated(){
            if i == 1{
                let p2 = HalfLine(p: p, r: firstPoint)
                let scaledFirst = p2.pointOnLine(n:settingsVar.tube.radie)
                tubeBase.setScaledFirst(scaledFirst)
                pointsList.append(scaledFirst) // top of screen
            }
            else if i == maxCount{
                let p2 = HalfLine(p: lastPoint, r: p)
                let scaledLast = p2.pointOnLine(n:settingsVar.tube.radie)
                tubeBase.setScaledLast(scaledLast)
                pointsList.append(scaledLast) // bottom of screen
            }
            if i == 0||i == maxCount{ continue }
            pointsList.append(p)
        }
        return pointsList
    }
    
    
   
    func initViewFromTubeDefaultValues(_ model:TubeDefault){
        settingsVar.tube = model
    }
    
    func initViewFromModelValues(_ model:TubeModel){
        settingsVar.tube.dimension = CGFloat(model.dimension)
        settingsVar.tube.segment = CGFloat(model.segment)
        settingsVar.tube.steel = CGFloat(model.steel)
        settingsVar.tube.grader = CGFloat(model.grader)
        settingsVar.tube.radie = CGFloat(model.radie)
        settingsVar.tube.lena = CGFloat(model.lena)
        settingsVar.tube.lenb = CGFloat(model.lenb)
        settingsVar.tube.center = CGFloat(model.center)
        settingsVar.tube.alreadyCalculated = model.alreadyCalculated
    }
    
    func initViewFromSharedValues(_ model:SharedTube) -> Bool{
        if let dimension = model.dimension,
           let segment = model.segment,
           let steel = model.steel,
           let grader = model.grader,
           let radie = model.radie,
           let lena = model.lena,
           let lenb = model.lenb,
           let center = model.center,
           let alreadyCalculated = model.alreadyCalculated{
            settingsVar.tube.dimension = dimension
            settingsVar.tube.segment = segment
            settingsVar.tube.steel = steel
            settingsVar.tube.grader = grader
            settingsVar.tube.radie = radie
            settingsVar.tube.lena = lena
            settingsVar.tube.lenb = lenb
            settingsVar.tube.center = center
            settingsVar.tube.alreadyCalculated = alreadyCalculated
            return true
        }
        return false
    }
    
    func initFromCache(){
        if let _ = settingsVar.stashedTube{
            settingsVar.drop()
            rebuild()
        }
    }
    
    func buildModelFromCurrentValues(_ model:TubeModel){
        model.id = UUID().uuidString
        model.dimension = Float(settingsVar.tube.dimension)
        model.segment = Float(settingsVar.tube.segment)
        model.steel = Float(settingsVar.tube.steel)
        model.grader = Float(settingsVar.tube.grader)
        model.radie = Float(settingsVar.tube.radie)
        model.lena = Float(settingsVar.tube.lena)
        model.lenb = Float(settingsVar.tube.lenb)
        model.center = Float(settingsVar.tube.center)
        model.alreadyCalculated = settingsVar.tube.alreadyCalculated
        model.date = Date()
        
    }
    
    func buildSharedTubeFromCurrentValues() -> SharedTube{
        return SharedTube(
            dimension: settingsVar.tube.dimension,
            segment: settingsVar.tube.segment,
            steel: settingsVar.tube.steel,
            grader: settingsVar.tube.grader,
            radie: settingsVar.tube.radie,
            lena: settingsVar.tube.lena,
            lenb: settingsVar.tube.lenb,
            center: settingsVar.tube.center,
            alreadyCalculated: settingsVar.tube.alreadyCalculated)
    }
    
    func collectModelRenderState() -> UInt16{
        var state:UInt16 = 0
        for op in stride(from: DrawOption.indexOf(op: .FULL_SIZE_MUFF),
                         to: DrawOption.indexOf(op: .ALL_OPTIONS),
                         by: 1){
            if userDefaultSettingsVar.drawOptions[op]{
                switch op{
                case DrawOption.indexOf(op: .DRAW_FILLED_MUFF):         state += RenderOption.indexOf(op: .FILL_MUFF)
                case DrawOption.indexOf(op: .DRAW_LINED_MUFF):          state += RenderOption.indexOf(op: .LINE_MUFF)
                case DrawOption.indexOf(op: .DRAW_SEE_THROUGH_MUFF):    state += RenderOption.indexOf(op: .SEE_THROUGH_MUFF)
                case DrawOption.indexOf(op: .SHOW_WHOLE_MUFF):          state += RenderOption.indexOf(op: .WHOLE_MUFF)
                case DrawOption.indexOf(op: .SHOW_SPLIT_MUFF):          state += RenderOption.indexOf(op: .SPLIT_MUFF)
                case DrawOption.indexOf(op: .FULL_SIZE_MUFF):           state += RenderOption.indexOf(op: .FULL_SIZE_MUFF)
                case DrawOption.indexOf(op: .SCALED_SIZE_MUFF):         state += RenderOption.indexOf(op: .SCALED_SIZE_MUFF)
                case DrawOption.indexOf(op: .SHOW_WORLD_AXIS):          state += RenderOption.indexOf(op: .WORLD_AXIS)
                case DrawOption.indexOf(op: .SHOW_STEEL):             state += RenderOption.indexOf(op: .SHOW_STEEL)
                case DrawOption.indexOf(op: .SHOW_MUFF):              state += RenderOption.indexOf(op: .SHOW_MUFF)
                default: break
                }
            }
        }
        return state
    }
}

// MARK: - USER DEFAULT
// TODO: - THIS CRASHES IF USER IS DELETED FROM FIREBASE BUT I DONT THINK THAT IS AN ISSUE, BUT FIX ANYWAYS
extension TubeViewModel{
    func loadUserDefaultValues() -> Bool{
        guard let userId = FirebaseAuth.userId else { return false }
        guard let userSettings = SharedPreference.loadUserSettingsFromStorage(userId) else{
            let preferredSetting = UserPreferredSetting()
            SharedPreference.writeNewUserSettingsToStorage(userId,userSetting: preferredSetting)
            userDefaultSettingsVar.preferredSetting = preferredSetting
            initViewFromTubeDefaultValues(preferredSetting.tubeDefault)
            userDefaultSettingsVar.showPreferredSettings()
            return true
        }
        userDefaultSettingsVar.preferredSetting = userSettings
        initViewFromTubeDefaultValues(userSettings.tubeDefault)
        userDefaultSettingsVar.showPreferredSettings()
        return true
    }
    
    func loadTubeDefaultValues(compareTubesMode:Bool = false){
        guard let userId = FirebaseAuth.userId,
              let userSettings = SharedPreference.loadUserSettingsFromStorage(userId)
        else{ return }
        initViewFromTubeDefaultValues(userSettings.tubeDefault)
        if compareTubesMode{
            settingsVar.setTubeDefault(userSettings.tubeDefault)
        }
    }
    
    func setUserdefaultDrawOption(with value:Bool,op:DrawOption){
        userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: op)] = value
    }
    
    func getUserdefaultDrawOptionValue(_ op:DrawOption) -> Bool{
        return userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: op)]
    }
    
    func saveUserDefaultDrawingValues(){
        guard let userId = FirebaseAuth.userId else { return }
        if userDefaultSettingsVar.drawingHasChanged{
            let drawOptions = userDefaultSettingsVar.drawOptions
            let tubeDefault = userDefaultSettingsVar.preferredSetting.tubeDefault
            let preferredSetting = UserPreferredSetting(
                 drawOptions: drawOptions,
                 tubeDefault: tubeDefault)
            SharedPreference.writeNewUserSettingsToStorage(userId,userSetting: preferredSetting)
            userDefaultSettingsVar.preferredSetting = preferredSetting
            userDefaultSettingsVar.showPreferredSettings()
        }
    }
    
    func saveUserDefaultTubeValues(){
        guard let userId = FirebaseAuth.userId else { return }
        let tubeDefault = settingsVar.generateTubeDefault
        let drawOptions = userDefaultSettingsVar.drawOptions
        let preferredSetting = UserPreferredSetting(
             drawOptions: drawOptions,
             tubeDefault: tubeDefault)
        SharedPreference.writeNewUserSettingsToStorage(userId,userSetting: preferredSetting)
        userDefaultSettingsVar.preferredSetting = preferredSetting
    }
}
