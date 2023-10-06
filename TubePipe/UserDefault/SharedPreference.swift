//
//  SharedPreference.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-01.
//

import Foundation

struct SettingsVar:Codable{
    var dimension:CGFloat = 720.0
    var segment:CGFloat = 1.0
    var steel:CGFloat = 300.0
    var grader:CGFloat = 90.0
    var radie:CGFloat = 500.0
    var lena:CGFloat = 500.0
    var lenb:CGFloat = 500.0
    var center: CGFloat = 0.0
    var first: CGFloat = 0.0
    var alreadyCalculated:Bool = false
    var redraw:Bool = false
    
    mutating func resetValues(){
        self.alreadyCalculated = false
        self.first = 0.0
        self.center = 0.0
    }
    
}

struct UserDefaultSettingsVar{
    var segment: String = ""
    var radius: String = ""
    var dimension: String = ""
    var length: String = ""
    var drawOptions: [Bool] = []
    
    var settingHasChanged:Bool{
        (segment != String(preferredSetting.segment) && legalInt(str: segment,max:1000)) ||
        (radius != String(preferredSetting.radius) && legalInt(str: radius,max:10000)) ||
        (dimension != String(preferredSetting.dimension) && legalInt(str: dimension,max:10000)) ||
        (length != String(preferredSetting.length) && legalInt(str: length,max:100000))
    }
    var drawingHasChanged:Bool{
        ((drawOptions.count != preferredSetting.drawOptions.count) ||
        (drawOptions != preferredSetting.drawOptions))
    }
    
    var preferredSetting:UserPreferredSetting = UserPreferredSetting()
    
    func specificDrawOptionHasChanged(_ index:Int) -> Bool{
        return drawOptions[index] != preferredSetting.drawOptions[index]
    }
    
    mutating func showPreferredSettings(){
        self.segment = String(preferredSetting.segment)
        self.radius = String(preferredSetting.radius)
        self.dimension = String(preferredSetting.dimension)
        self.length = String(preferredSetting.length)
        self.drawOptions = preferredSetting.drawOptions
    
    }
    
    func legalInt(str:String,max:Int32) ->Bool{
        guard let val = Int32(str) else { return false }
        return val > 0 && val <= max
    }
    
}

class UserPreferredSetting: NSObject, NSCoding ,NSSecureCoding{
    static var supportsSecureCoding: Bool { return true}
    
    var segment: Int32
    var radius: Int32
    var dimension: Int32
    var length: Int32
    var drawOptions: [Bool]
    
    init(segment: Int32?,radius:Int32?,dimension:Int32?,length:Int32?,drawOptions:[Bool]?) {
        self.segment = segment ?? 100
        self.radius = radius ?? 5000
        self.dimension = dimension ?? 5000
        self.length = length ?? 10000
        self.drawOptions = drawOptions ?? Array.init(repeating: true, count: DrawOption.indexOf(op: .ALL_OPTIONS))
    }
    
    convenience override init() {
        var arr = Array.init(repeating: false, count: DrawOption.indexOf(op: .ALL_OPTIONS))
        arr[DrawOption.indexOf(op: .LABELSDEGREES)] = true
        arr[DrawOption.indexOf(op: .LABELSLENGTH)] = true
        arr[DrawOption.indexOf(op: .CUTLINES)] = true
        arr[DrawOption.indexOf(op: .ADD_ONE_HUNDRED)] = true
        arr[DrawOption.indexOf(op: .KEEP_DEGREES)] = true
        arr[DrawOption.indexOf(op: .AUTO_ALIGN)] = true
        arr[DrawOption.indexOf(op: .SHOW_WHOLE_MUFF)] = true
        arr[DrawOption.indexOf(op: .DRAW_FILLED_MUFF)] = true
        arr[DrawOption.indexOf(op: .FULL_SIZE_MUFF)] = true
        arr[DrawOption.indexOf(op: .SHOW_WORLD_AXIS)] = true
        self.init(segment: nil,radius:nil,dimension:nil,length:nil,drawOptions: arr)
    }
  
    required convenience init(coder aDecoder: NSCoder) {
        let segment = aDecoder.decodeInt32(forKey: "segment")
        let radius = aDecoder.decodeInt32(forKey: "radius")
        let dimension = aDecoder.decodeInt32(forKey: "dimension")
        let length = aDecoder.decodeInt32(forKey: "length")
        let drawOption = aDecoder.decodeObject(forKey: "drawOption") as? [Bool]
        self.init(segment:segment,radius:radius,dimension:dimension,length:length,drawOptions: drawOption)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(segment, forKey: "segment")
        aCoder.encode(radius, forKey: "radius")
        aCoder.encode(dimension, forKey: "dimension")
        aCoder.encode(length, forKey: "length")
        aCoder.encode(drawOptions, forKey: "drawOption")
    }
    
}

class SharedPreference {
    static let userDefault = UserDefaults.standard
   
    static func writeNewUserSettingsToStorage(_ key: String,userSetting: UserPreferredSetting){
        do{
            let encodedData: Data = try NSKeyedArchiver.archivedData(
                withRootObject: userSetting,
                requiringSecureCoding: false)
            userDefault.set(encodedData, forKey: key)
        }
        catch{
            debugLog(object: error)
        }
    }
    
    static func loadUserSettingsFromStorage(_ key: String) -> UserPreferredSetting? {
        guard let decodedData = userDefault.data(forKey: key) else { return nil }
        do{
            let decodedUserSetting = try (NSKeyedUnarchiver.unarchivedObject(
                ofClasses: [NSArray.self, NSString.self, NSNumber.self, UserPreferredSetting.self], from: decodedData) as? UserPreferredSetting)
            return decodedUserSetting
            
        }
        catch{
            debugLog(object: error)
        }
        return nil
    }
    
    static func removeUserData(_ key:String){
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    static func writeData(key: String,value: Any){
        userDefault.setValue(value, forKey: key)
        userDefault.synchronize()
    }
    
    static func getIntValue(key : String) -> Int{
        return userDefault.object(forKey: key) == nil ? 0 : userDefault.integer(forKey: key)
    }
    
    static func getDoubleValue(key : String) -> Double{
        return userDefault.object(forKey: key) == nil ? 0.0 : userDefault.double(forKey: key)
    }
    
    static func getStringValue(key : String) -> String{
        return userDefault.object(forKey: key) == nil ? "" : userDefault.string(forKey: key) ?? ""
    }
    
    static func getBoolValue(key : String) -> Bool{
        return userDefault.object(forKey: key) == nil ? false : userDefault.bool(forKey: key)
    }
    
}

