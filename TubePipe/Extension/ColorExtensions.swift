//
//  ColorExtensions.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI

extension UIColor{
    static let backgroundPrimary = UIColor(red:36,green:36,blue:36)
    static let cardBackgroundPrimary = UIColor(red:46,green:46,blue:46)
    static let planeColor = UIColor(named: "planeColor") ?? UIColor.blue
    
    convenience init(red:Int,green:Int,blue:Int,a:CGFloat = 1.0) {
        self.init(red:CGFloat(red)/255.0,
                  green:CGFloat(green)/255.0,
                  blue:CGFloat(blue)/255.0,
                  alpha:CGFloat(a))
    }
}

extension Color {
    
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
    
    init(dRed red:Double,dGreen green:Double,dBlue blue:Double){
        self.init(red: red/255.0,green: green/255.0,blue: blue/255.0)
    }
    
    static var random: Color { Color(red: .random(in: 0...1),green: .random(in: 0...1),blue: .random(in: 0...1))}
    
    static var backgroundPrimary:Color          = Color(hex:0xededed)
    static var backgroundSecondary:Color        = Color(hex:0xEEEEEE)
    static var backgroundButton:Color           = Color(hex:0xededed)
    static var backgroundSheetField:Color       = Color.gray.opacity(0.01)
    static var calendarButton:Color             = Color.black
    static var sheetCloseButton:Color           = Color.systemBlue
    static var editorieButton:Color             = Color.systemBlue
    static var APP_MID_BACKGROUND_COLOR: Color  = Color(dRed: 62.0, dGreen: 62.0, dBlue: 62.0)
   
    // MARK: - Text Colors
    static let lightText = Color(UIColor.lightText)
    static let darkText = Color(UIColor.darkText)
    static let placeholderText = Color(UIColor.placeholderText)

    // MARK: - Label Colors
    static let label = Color(UIColor.label)
    static let secondaryLabel = Color(UIColor.secondaryLabel)
    static let tertiaryLabel = Color(UIColor.tertiaryLabel)
    static let quaternaryLabel = Color(UIColor.quaternaryLabel)

    // MARK: - Background Colors
    static let systemBackground = Color(UIColor.systemBackground)
    static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
    static let tertiarySystemBackground = Color(UIColor.tertiarySystemBackground)
    
    // MARK: - Fill Colors
    static let systemFill = Color(UIColor.systemFill)
    static let secondarySystemFill = Color(UIColor.secondarySystemFill)
    static let tertiarySystemFill = Color(UIColor.tertiarySystemFill)
    static let quaternarySystemFill = Color(UIColor.quaternarySystemFill)
    
    // MARK: - Grouped Background Colors
    static let systemGroupedBackground = Color(UIColor.systemGroupedBackground)
    static let secondarySystemGroupedBackground = Color(UIColor.secondarySystemGroupedBackground)
    static let tertiarySystemGroupedBackground = Color(UIColor.tertiarySystemGroupedBackground)
    
    // MARK: - Gray Colors
    static let systemGray  = Color(UIColor.systemGray)
    static let darkGray    = Color(UIColor.darkGray)
    static let systemGray2 = Color(UIColor.systemGray2)
    static let systemGray3 = Color(UIColor.systemGray3)
    static let systemGray4 = Color(UIColor.systemGray4)
    static let systemGray5 = Color(UIColor.systemGray5)
    static let systemGray6 = Color(UIColor.systemGray6)
    
    // MARK: - Other Colors
    static let separator = Color(UIColor.separator)
    static let opaqueSeparator = Color(UIColor.opaqueSeparator)
    static let link = Color(UIColor.link)
    
    // MARK: System Colors
    static let systemBlue = Color(UIColor.systemBlue)
    static let systemPurple = Color(UIColor.systemPurple)
    static let systemGreen = Color(UIColor.systemGreen)
    static let systemYellow = Color(UIColor.systemYellow)
    static let systemOrange = Color(UIColor.systemOrange)
    static let systemPink = Color(UIColor.systemPink)
    static let systemRed = Color(UIColor.systemRed)
    static let systemTeal = Color(UIColor.systemTeal)
    static let systemIndigo = Color(UIColor.systemIndigo)
    
    // MARK: JAVA COLORS
    static var GOLD:Color                   =   Color(hex: 0xFFD700)
    static var GOLDENROD:Color              =   Color(hex: 0xDAA520)
    static var LAWNGREEN:Color              =   Color(hex: 0x7CFC00)
    static var LIME:Color                   =   Color(hex: 0x00FF00)
    static var TURQUOISE:Color              =   Color(hex: 0x40E0D0)
    static var MIDNIGHTBLUE:Color           =   Color(hex: 0x191970)
    static var NAVY:Color                   =   Color(hex: 0x000080)
    static var OLIVEDRAB:Color              =   Color(hex: 0x6B8E23)
    static var DARKVIOLET:Color             =   Color(hex: 0x9400D3)
    static var DARKSEAGREEN:Color           =   Color(hex: 0x8FBC8F)
    static var MEDIUMSPRINGGREEN:Color      =   Color(hex: 0x00FA9A)
    static var DEEPSKYBLUE:Color            =   Color(hex: 0x00BFFF)
    static var DARKGOLDENROD:Color          =   Color(hex: 0xB8860B)
    static var OLIVE:Color                  =   Color(hex: 0x808000)
    static var YELLOWGREEN:Color            =   Color(hex: 0x9ACD32)
    static var TEAL:Color                   =   Color(hex: 0x008080)
    static var ROYALBLUE:Color              =   Color(hex: 0x4169E1)
    static var DARKMAGENTA:Color            =   Color(hex: 0x8B008B)
    static var VIOLET:Color                 =   Color(hex: 0xEE82EE)
    static var FUCHSIA:Color                =   Color(hex: 0xFF00FF)
    static var DARKORANGE:Color             =   Color(hex: 0xFF8C00)
    static var NAVAJOWHITE:Color            =   Color(hex: 0xFFDEAD)
    static var ROSYBROWN:Color              =   Color(hex: 0xBC8F8F)
    static var DARKORCHID:Color             =   Color(hex: 0x9932CC)
    static var DARKSLATEBLUE:Color          =   Color(hex: 0x483D8B)
    static var FORESTGREEN:Color            =   Color(hex: 0x228B22)
    static var CORAL:Color                  =   Color(hex: 0xFF7F50)
    static var CRIMSON:Color                =   Color(hex: 0xDC143C)
    static var WHITESMOKE:Color             =   Color(hex: 0xF5F5F5)
    static var PALEGOLDENROD:Color          =   Color(hex: 0xEEE8AA)
    static var DARKKHAKI:Color              =   Color(hex: 0xBDB76B)
    static var KHAKI:Color                  =   Color(hex: 0xF0E68C)
    static var GHOSTWHITE:Color             =   Color(hex: 0xF8F8FF)
    
    static subscript(name: String) -> Color {
            switch name {
            case "A": return Color.FORESTGREEN
            case "B": return Color.DARKMAGENTA
            case "C": return Color.CRIMSON
            case "D": return Color.DARKORCHID
            case "E": return Color.LIME
            case "F": return Color.ROYALBLUE
            case "G": return Color.GOLD
            case "H": return Color.DARKGOLDENROD
            case "I": return Color.DEEPSKYBLUE
            case "J": return Color.NAVAJOWHITE
            case "K": return Color.KHAKI
            case "L": return Color.DARKSEAGREEN
            case "M": return Color.DARKORCHID
            case "N": return Color.NAVY
            case "O": return Color.OLIVE
            case "P": return Color.OLIVEDRAB
            case "Q": return Color.TURQUOISE
            case "R": return Color.ROSYBROWN
            case "S": return Color.DARKSLATEBLUE
            case "T": return Color.TEAL
            case "U": return Color.FUCHSIA
            case "V": return Color.VIOLET
            case "W": return Color.LAWNGREEN
            case "X": return Color.DARKORANGE
            case "Y": return Color.YELLOWGREEN
            case "Z": return Color.DARKVIOLET
            case "Å": return Color.MIDNIGHTBLUE
            case "Ä": return Color.CORAL
            case "Ö": return Color.VIOLET
            case "?": return Color.MEDIUMSPRINGGREEN
            default: return Color.DARKSLATEBLUE
            }
    }
}
