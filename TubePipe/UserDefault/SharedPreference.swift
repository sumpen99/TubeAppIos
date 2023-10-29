//
//  SharedPreference.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-01.
//

import Foundation

class Box<T> {
   let boxed: T
   init(_ thingToBox: T) {
       boxed = thingToBox
   }
}

struct SettingsVar:Codable{
    var dimension:CGFloat = 0
    var segment:CGFloat = 0
    var steel:CGFloat = 0
    var grader:CGFloat = 0
    var radie:CGFloat = 0
    var lena:CGFloat = 0
    var lenb:CGFloat = 0
    var overlap:CGFloat = 0
    var center: CGFloat = 0.0
    var first: CGFloat = 0.0
    var alreadyCalculated:Bool = false
    var redraw:Bool = false
    var stashedValues: TubeDefault?
    var forceAutoAlign: Bool = false
    var generateTubeDefault:TubeDefault{
        TubeDefault(
            dimension: dimension,
            segment: segment,
            steel: steel,
            grader: grader,
            radie: radie,
            lena: lena,
            lenb: lenb,
            overlap: overlap,
            center: center)
    }
    
    var hasChanges:Bool{
        if let stashedValues = stashedValues{
            return (dimension != stashedValues.dimension    ||
                    segment != stashedValues.segment        ||
                    steel != stashedValues.steel            ||
                    grader != stashedValues.grader          ||
                    radie != stashedValues.radie            ||
                    lena != stashedValues.lena              ||
                    lenb != stashedValues.lenb              ||
                    center != stashedValues.center)
        }
        return false
    }
    
    mutating func resetCalculationMode(){
        self.alreadyCalculated = false
        self.first = 0.0
        self.center = 0.0
    }
    
    mutating func stash(){
        stashedValues = generateTubeDefault
        forceAutoAlign = true
    }
    
    
    mutating func drop(){
        if let stashedValues = stashedValues{
            dimension = stashedValues.dimension
            segment = stashedValues.segment
            steel = stashedValues.steel
            grader = stashedValues.grader
            radie = stashedValues.radie
            lena = stashedValues.lena
            lenb = stashedValues.lenb
            center = stashedValues.center
            self.stashedValues = nil
            self.forceAutoAlign = false
        }
    }
    
}

struct TubeDefault: Equatable,Codable{
    var dimension:CGFloat = 160.0
    var segment:CGFloat = 1.0
    var steel:CGFloat = 65.0
    var grader:CGFloat = 90.0
    var radie:CGFloat = 200.0
    var lena:CGFloat = 220.0
    var lenb:CGFloat = 220.0
    var overlap:CGFloat = 100.0
    var center:CGFloat = 0.0
    
    static func == (lhs: TubeDefault, rhs: TubeDefault) -> Bool {
        return(
        lhs.dimension == rhs.dimension &&
        lhs.segment == rhs.segment &&
        lhs.steel == rhs.steel &&
        lhs.grader == rhs.grader &&
        lhs.radie == rhs.radie &&
        lhs.lena == rhs.lena &&
        lhs.lenb == rhs.lenb &&
        lhs.overlap == rhs.overlap)
    }
}

struct UserDefaultSettingsVar{
    var drawOptions: [Bool] = []
    var preferredSetting:UserPreferredSetting = UserPreferredSetting()
      
    var drawingHasChanged:Bool{
        ((drawOptions.count != preferredSetting.drawOptions.count) ||
        (drawOptions != preferredSetting.drawOptions))
    }
    
    mutating func showPreferredSettings(){
        self.drawOptions = preferredSetting.drawOptions
    }
}

class UserPreferredSetting: NSObject, NSCoding ,NSSecureCoding,Encodable,Decodable{
    static var supportsSecureCoding: Bool { return true }
    var drawOptions: [Bool]
    var tubeDefault:TubeDefault
    
    init(drawOptions:[Bool]?,tubeDefault:TubeDefault?) {
       self.drawOptions = drawOptions ?? Array.init(repeating: true,
                                                    count: DrawOption.indexOf(op: .ALL_OPTIONS))
       self.tubeDefault = tubeDefault ?? TubeDefault()
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
        arr[DrawOption.indexOf(op: .SHOW_STEEL)] = true
        arr[DrawOption.indexOf(op: .SHOW_MUFF)] = true
        self.init(drawOptions: arr,tubeDefault: nil)
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let drawOption = aDecoder.decodeObject(forKey: "drawOption") as? [Bool]
        let tubeDefault = aDecoder.decodeObject(forKey: "tubeDefault") as? TubeDefault
        self.init(drawOptions: drawOption,tubeDefault: tubeDefault)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(drawOptions, forKey: "drawOption")
        aCoder.encode(tubeDefault, forKey: "tubeDefault")
    }
    
}

class SharedPreference {
    static let userDefault = UserDefaults.standard
   
    static func writeNewUserSettingsToStorage(_ key: String,userSetting: UserPreferredSetting){
        do{
            if let encodedSettings = try JSONSerialization.jsonObject(with: JSONEncoder().encode(userSetting)) as? [String: Any]{
                let encodedData: Data = try NSKeyedArchiver.archivedData(
                    withRootObject: encodedSettings,
                    requiringSecureCoding: false)
                userDefault.set(encodedData, forKey: key)
            }
            
        }
        catch{
            debugLog(object: error)
        }
    }
    
    static func loadUserSettingsFromStorage(_ key: String) -> UserPreferredSetting? {
        guard let decodedData = userDefault.data(forKey: key) else { return nil }
        do{
            if let decodedDic = try NSKeyedUnarchiver.unarchivedObject(
                ofClasses: [NSArray.self, NSString.self, NSNumber.self,NSDictionary.self], from: decodedData) as? NSDictionary{
                let decodedUserSetting = try JSONDecoder().decode(UserPreferredSetting.self, from: JSONSerialization.data(withJSONObject: decodedDic))
                return decodedUserSetting
            }
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

