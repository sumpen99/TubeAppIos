//
//  NumberExtensions.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI

enum RoundingPrecision {
    case ONES
    case TENTHS
    case HUNDREDTHS
}

extension Int?{
    func zeroString() -> String{
        guard let value = self else { return "" }
        return value < 10 ? "0\(value)" : "\(value)"
    }
}

extension Int {
    static func getUniqueRandomNumbers(min: Int, max: Int, count: Int) -> [Int] {
        var set = Set<Int>()
        while set.count < count {
            set.insert(Int.random(in: min...max))
        }
        return Array(set)
    }
    
    func zeroString() -> String{
        return self < 10 ? "0\(self)" : "\(self)"
    }

}

extension CGFloat{
    
    func remapValue(min1:CGFloat,max1:CGFloat,min2:CGFloat,max2:CGFloat) -> CGFloat{
        return CGFloat((max2-min2) * (self-min1) / (max1-min1) + min2)
    }
    
    func degToRad() -> CGFloat{
        return self * (CGFloat.pi/180.0)
    }
    
    func radToDeg() -> CGFloat{
        return self * (180.0/CGFloat.pi)
    }
    
    func toStringWith(precision:String = "%.2f") ->String{
        return String(format:precision, self)
    }
    
    func roundWith(precision: RoundingPrecision = .HUNDREDTHS) -> CGFloat{
        switch precision {
        case .ONES:
            return self.rounded(.down)
        case .TENTHS:
            return CGFloat(self*10).rounded(.down) / 10.0
        case .HUNDREDTHS:
            return CGFloat(self*100).rounded(.down) / 100.0
        }
    }
}
