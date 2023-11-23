//
//  TubeDocumentView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-07-20.
//

import SwiftUI

enum ActiveImagePickerActionSheet: Identifiable {
    case ORIGINAL_PICKER
    case MULTIPLE_PICKER
    
    var id: Int {
        hashValue
    }
}

struct DocumentContent:Codable{
    var isSaving:Bool = false
    var message:String = ""
    var title:String = ""
    var email:String = ""
    var date:Date?
    var data:Data?
    var clearAttachedImage:Bool = false
    
    var documentId:String { UUID().uuidString }
    var storageId:String? { data == nil ? nil : UUID().uuidString }
    var enteredEmail:String? { email.isEmpty ? nil : email }
    
    var isNotAValidDocument:Bool{
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let message = message.trimmingCharacters(in: .whitespacesAndNewlines)
        return (title.isEmpty||message.isEmpty)
    }
    
    mutating func trim(){
        message = message.trimmingCharacters(in: .whitespacesAndNewlines)
        title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    mutating func clearDocument(){
        title = ""
        message = ""
        email = ""
        date = nil
        data = nil
        clearAttachedImage.toggle()
    }
    
}

struct TubeDocumentView: View{
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tubeViewModel: TubeViewModel
    let segTypes:[SegType] = [.LENA,.LENB,.SEG1,.SEG2]
    let SEGMENT_HEIGHT:CGFloat = 50.0
  
    var document:some View{
        List{
            muffSection
            summarySection
            ForEach(segTypes,id:\.self){ segType in
                getSegmentSection(segment: tubeViewModel.muffDetails.getSegmenIfItExists(segType: segType))
            }
        }
        .listStyle(.automatic)
    }
    
    //MARK: - MAIN BODY
    var body: some View{
        AppBackgroundSheetStack(content: {
            VStack(spacing:0){
                TopMenu(title: "Document", actionCloseButton: closeView)
                document.vTop()
            }
        })
        
     }
    
    //MARK: - BUTTON FUNCTIONS
    func closeView(){
        dismiss()
    }
    
}


extension TubeDocumentView{
   
    @ViewBuilder
    func getSegmentSection(segment:Segment?) -> some View{
        if let segment = segment{
            let numberOfSegments = ((segment.seg_type == .LENA)||(segment.seg_type == .LENB)) ? 1 :
                        (segment.seg_type == .SEG1 ? tubeViewModel.muffDetails.numSeg1 : tubeViewModel.muffDetails.numSeg2)
            Section {
                VStack(spacing:10){
                    SubHeaderSubHeaderView(subMain: Text("Antal:"), subSecond: Text("\(numberOfSegments)st"))
                    SubHeaderSubHeaderView(subMain: Text("Angle1:"), subSecond: Text("\(segment.angle1/2.0,specifier: "%.2f")°"))
                    SubHeaderSubHeaderView(subMain: Text("Angle2:"), subSecond: Text("\(segment.angle2/2.0,specifier: "%.2f")°"))
                    SubHeaderSubHeaderView(subMain: Text("Inner length:"), subSecond: Text(segment.innerLength))
                    SubHeaderSubHeaderView(subMain: Text("Outer length:"), subSecond: Text(segment.outerLength))
                 }
            } header: {
                Text(segment.seg_type.rawValue).listSectionHeader()
            } footer: {
                Text("")
            }
        }
    }
    
    var muffSection: some View{
        return Section { muff } header: { Text("Muff").listSectionHeader() } footer: { Text("") }
    }
    
    var muff: some View{
        return GeometryReader{ reader in
            ScrollView(.horizontal,showsIndicators: false){
                HStack(spacing:1.0){
                    ForEach(tubeViewModel.muffDetails.seg_list,id:\.self){ seg in
                        switch seg.seg_type{
                        case .LENA:
                            ZStack{
                                lenA(sectionWidth: reader.size.width,segment: seg)
                                Text("A")
                            }
                        case .LENB:
                            ZStack{
                                lenB(sectionWidth: reader.size.width,segment: seg)
                                Text("B")
                            }
                        default:
                            ZStack{
                                getSegment(sectionWidth: reader.size.width,segment: seg)
                                Text(seg.seg_type == SegType.SEG1 ? "1" : "2")
                            }
                        }
                    }
                }
                
            }
           
        }
        .frame(height:SEGMENT_HEIGHT)
    }
    
    var summarySection: some View{
        return Section {
            VStack(spacing:10){
                SubHeaderSubHeaderView(subMain: Text("Total length:"),
                                       subSecond: Text("\(tubeViewModel.muffDetails.sum_len,specifier: "%.0f") mm"))
                SubHeaderSubHeaderView(subMain: Text("Degrees:"), subSecond: Text("\(Int(tubeViewModel.settingsVar.tube.grader))°"))
                SubHeaderSubHeaderView(subMain: Text("Dimension:"), subSecond: Text("ø\(Int(tubeViewModel.settingsVar.tube.dimension))"))
                SubHeaderSubHeaderView(subMain: Text("Steel:"), subSecond: Text("ø\(Int(tubeViewModel.settingsVar.tube.steel))"))
                SubHeaderSubHeaderView(subMain: Text("Radius:"), subSecond: Text("\(Int(tubeViewModel.settingsVar.tube.radie)) mm"))
                SubHeaderSubHeaderView(subMain: Text("LenA:"), subSecond: Text("\(Int(tubeViewModel.settingsVar.tube.lena)) mm"))
                SubHeaderSubHeaderView(subMain: Text("LenB:"), subSecond: Text("\(Int(tubeViewModel.settingsVar.tube.lenb)) mm"))
             }
       } header:{
            Text("Summary").listSectionHeader()
        } footer:{
            Text("")
        }
        
    }
    
    func lenA(sectionWidth:CGFloat,segment:Segment) -> some View{
        let newWidth = segment.outer.remapValue(min1: 0.0, max1: tubeViewModel.muffDetails.sum_len,
                                                min2: SEGMENT_HEIGHT, max2: sectionWidth)
        
        var p0,p1,p2,p3:CGPoint
        let angle2 = segment.angle2/2.0
        let rad = CGFloat(angle2).degToRad()
        let x2 = SEGMENT_HEIGHT * sin(rad)
        
        p0 = CGPoint(x: 0.0, y: 0.0)
        p1 = CGPoint(x: newWidth, y: 0.0)
        p2 = CGPoint(x: newWidth-x2, y: SEGMENT_HEIGHT)
        p3 = CGPoint(x: 0.0, y: SEGMENT_HEIGHT)
     
        return Path{ path in
                        path.move(to: p0)
                        path.addLine(to: p1)
                        path.addLine(to: p2)
                        path.addLine(to: p3)
                        path.closeSubpath()
                    }
                    .boxStroke()
                    .frame(width: newWidth)
    }
    
    func lenB(sectionWidth:CGFloat,segment:Segment) -> some View{
        let newWidth = segment.outer.remapValue(min1: 0.0, max1: tubeViewModel.muffDetails.sum_len,
                                                min2: SEGMENT_HEIGHT, max2: sectionWidth)
        
        var p0,p1,p2,p3:CGPoint
        let angle2 = segment.angle2/2.0
        let rad = CGFloat(angle2).degToRad()
        let x0 = SEGMENT_HEIGHT * sin(rad)
        
        if segment.index%2 == 0{
            p0 = CGPoint(x: 0.0, y: 0.0)
            p1 = CGPoint(x: newWidth, y: 0.0)
            p2 = CGPoint(x: newWidth, y: SEGMENT_HEIGHT)
            p3 = CGPoint(x: x0, y: SEGMENT_HEIGHT)
        }
        else{
            p0 = CGPoint(x: x0, y: 0.0)
            p1 = CGPoint(x: newWidth, y: 0.0)
            p2 = CGPoint(x: newWidth, y: SEGMENT_HEIGHT)
            p3 = CGPoint(x: 0.0, y: SEGMENT_HEIGHT)
        }
        
     
        return Path{ path in
                        path.move(to: p0)
                        path.addLine(to: p1)
                        path.addLine(to: p2)
                        path.addLine(to: p3)
                        path.closeSubpath()
                    }
                    .boxStroke()
                    .frame(width: newWidth)
    }
    
    func getSegment(sectionWidth:CGFloat,segment:Segment) -> some View{
        let newWidth = segment.outer.remapValue(min1: 0.0, max1: tubeViewModel.muffDetails.sum_len,
                                                min2: SEGMENT_HEIGHT, max2: sectionWidth)
        
        var p0,p1,p2,p3:CGPoint
        let angle1 = segment.angle1/2.0
        let angle2 = segment.angle2/2.0
        let rad0 = CGFloat(angle1).degToRad()
        let rad1 = CGFloat(angle2).degToRad()
        
        if segment.index%2 == 0{
            let x2 = newWidth - (SEGMENT_HEIGHT * sin(rad1))
            let x3 = SEGMENT_HEIGHT * sin(rad0)
            
            p0 = CGPoint(x: 0.0, y: 0.0)
            p1 = CGPoint(x: newWidth, y: 0.0)
            p2 = CGPoint(x: x2, y: SEGMENT_HEIGHT)
            p3 = CGPoint(x: x3, y: SEGMENT_HEIGHT)
        }
        else{
            let x0 = SEGMENT_HEIGHT * sin(rad0)
            let x1 = newWidth - (SEGMENT_HEIGHT * sin(rad1))
            
            p0 = CGPoint(x: x0, y: 0.0)
            p1 = CGPoint(x: x1, y: 0.0)
            p2 = CGPoint(x: newWidth, y: SEGMENT_HEIGHT)
            p3 = CGPoint(x: 0.0, y: SEGMENT_HEIGHT)
        }
      
        return Path { path in
                        path.move(to: p0)
                        path.addLine(to: p1)
                        path.addLine(to: p2)
                        path.addLine(to: p3)
                        path.closeSubpath()
                    }
                    .boxStroke()
                    .frame(width: newWidth)
    }
}
