//
//  MuffDetails.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI

struct MuffDetails{
    var seg_list:[Segment] = []
    var sum_len:CGFloat = 0.0
    var segments:Int = 0
    var first_degree:CGFloat = 0.0
    var cut_degree:CGFloat = 0.0
    var max_seg_out:CGFloat = 0.0
    var max_seg_in:CGFloat = 0.0
    var dim:CGFloat = 0.0
    var numSeg1:Int = 0
    var numSeg2:Int = 0
   
    func getSegmenIfItExists(segType:SegType) -> Segment?{
        if seg_list.count < 2 { return nil }
        switch segType{
            case .LENA:
                return seg_list[0]
            case .LENB:
                return seg_list[seg_list.count-1]
            default:
                for index in 1..<seg_list.count-1{
                    if seg_list[index].seg_type == segType{
                        return seg_list[index]
                    }
                }
                return nil
        }
    }
    
    mutating func calcTotLen(){
        var sum:CGFloat = 0.0
        var cnt = 0
        for seg in seg_list{
            if cnt % 2 != 0{
                sum += seg.inner
            }
            else{
                sum += seg.outer
            }
            
            if seg.seg_type == .SEG1 { numSeg1 += 1}
            else if seg.seg_type == .SEG2 { numSeg2 += 1}
            
            cnt += 1
        }
        self.sum_len = sum.roundWith(precision: .HUNDREDTHS)
    }
    
    mutating func getMinMaxSeg(){
        var max_out = 0.0
        var max_in = 0.0
        for seg in seg_list{
            max_out = max(max_out,seg.outer)
            max_in = max(max_in,seg.inner)
        }
        self.max_seg_out = max_out
        self.max_seg_in = max_in
    }
    
    mutating func setDegree(first:CGFloat,cut:CGFloat){
        self.first_degree = first.roundWith(precision: .HUNDREDTHS)
        self.cut_degree = cut.roundWith(precision: .HUNDREDTHS)
    }
    
    func getSegType(_ seg_name:String)->(segment:Segment?,type:SegType?){
        guard let t = SegType(rawValue:seg_name) else { return (segment:nil,type:nil) }
        for seg in seg_list{
            if seg.seg_type == t{
                return (segment:seg,type:t)
            }
        }
        return (segment:nil,type:nil)
        
    }
    
    func getLenA() -> CGFloat?{
        for seg in seg_list{
            if seg.seg_type == SegType.LENA{
                return seg.inner
            }
        }
        return nil
    }
}
