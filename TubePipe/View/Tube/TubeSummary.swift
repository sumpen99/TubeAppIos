//
//  TubeSummary.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-04.
//

import SwiftUI

struct TubeModelSummary:View{
    let tubeModel:TubeModel
    
    var body:some View{
        Section(content:{
            VStack(spacing:10){
                BoldSubHeaderSubHeaderView(subMain: Text("Segment:"), subSecond: Text("\(Int(tubeModel.segment))st"))
                BoldSubHeaderSubHeaderView(subMain: Text("Degrees:"), subSecond: Text("\(Int(tubeModel.grader))°"))
                BoldSubHeaderSubHeaderView(subMain: Text("Dimension:"), subSecond: Text("ø\(Int(tubeModel.dimension))"))
                BoldSubHeaderSubHeaderView(subMain: Text("Steel:"), subSecond: Text("ø\(Int(tubeModel.steel))"))
                BoldSubHeaderSubHeaderView(subMain: Text("Radius:"), subSecond: Text("\(Int(tubeModel.radie)) mm"))
                BoldSubHeaderSubHeaderView(subMain: Text("LenA:"), subSecond: Text("\(Int(tubeModel.lena)) mm"))
                BoldSubHeaderSubHeaderView(subMain: Text("LenB:"), subSecond: Text("\(Int(tubeModel.lenb)) mm"))
            }},
            header: {Text("Tube information:").listSectionHeader()}) {
        }
    }
}

struct SharedTubeSummary:View{
    let sharedTube:SharedTube
    
    var body:some View{
        Section(content:{
            VStack(spacing:10){
                BoldSubHeaderSubHeaderView(subMain: Text("Segment:"), subSecond: Text("\(Int(sharedTube.segment ?? 0.0))st"))
                BoldSubHeaderSubHeaderView(subMain: Text("Degrees:"), subSecond: Text("\(Int(sharedTube.grader ?? 0.0))°"))
                BoldSubHeaderSubHeaderView(subMain: Text("Dimension:"), subSecond: Text("ø\(Int(sharedTube.dimension ?? 0.0))"))
                BoldSubHeaderSubHeaderView(subMain: Text("Steel:"), subSecond: Text("ø\(Int(sharedTube.steel ?? 0.0))"))
                BoldSubHeaderSubHeaderView(subMain: Text("Radius:"), subSecond: Text("\(Int(sharedTube.radie ?? 0.0)) mm"))
                BoldSubHeaderSubHeaderView(subMain: Text("LenA:"), subSecond: Text("\(Int(sharedTube.lena ?? 0.0)) mm"))
                BoldSubHeaderSubHeaderView(subMain: Text("LenB:"), subSecond: Text("\(Int(sharedTube.lenb ?? 0.0)) mm"))
            }
            },
                header: {Text("Attached Tube:").listSectionHeader(color: Color.white)}) {
            }
    }
}
