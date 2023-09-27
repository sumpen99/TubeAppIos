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
    
    static var backgroundPrimary:Color { Color(hex:0x424242) }
    static var backgroundPrimary1:Color { Color(hex:0x424242) }
    static var backgroundPrimary2:Color { Color(hex:0x303030) }
    
    static var backgroundSecondary:Color { Color(hex:0xEEEEEE)}
    static var backgroundSecondary1:Color { Color(hex:0xFAFAFA)}
    static var backgroundSecondary3:Color { Color(hex:0xF5F5F5)}
    static var backgroundSecondary4:Color { Color(hex:0xEEEEEE)}
    static var backgroundSecondary2:Color { Color(hex:0xE0E0E0)}
    static var backgroundSecondary5:Color { Color(hex:0x424242)}
    
    //static var backgroundThirdary:Color { Color(hex:0xBDBDBD)}
    static var backgroundThirdary:Color { Color.systemBlue}
    
    static var calendarBackground:Color{ Color.systemBlue }
    
    static var requestCardBackground: Color{ Color.WHITESMOKE }
    
    static var APP_BACKGROUND_COLOR: Color { Color(hex: 0x0) }
    static var APP_TAB_BACKGROUND_COLOR: Color { Color(hex:0xAAABAA) }
    static var APP_MID_BACKGROUND_COLOR: Color { Color(dRed: 62.0, dGreen: 62.0, dBlue: 62.0) }

    static var APP_BACKGROUND_UI_COLOR: UIColor { UIColor(Color.backgroundPrimary) }
    static var APP_TAB_BACKGROUND_UI_COLOR: UIColor { UIColor(Color.backgroundPrimary) }
    static var APP_TAB_BACKGROUND_COLOR_ORG: Color { Color.backgroundPrimary }
    
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
    static let systemGray = Color(UIColor.systemGray)
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
    static var LIGHTGREEN:Color { Color(hex: 0x90ee90)}
    static var LIGHTBLUE:Color { Color(hex: 0xb7e9f7)}
    static var LIGHTORANGE:Color { Color(hex: 0xfbbf77)}
    static var LIGHTRED:Color { Color(hex: 0xffcccb)}
    static var MAROON:Color { Color(hex: 0x800000)}
    static var INDIANRED:Color { Color(hex: 0xCD5C5C)}
    static var DARKRED:Color { Color(hex: 0x8B0000)}
    static var LIGHTCORAL:Color { Color(hex: 0xF08080)}
    static var DARKSALMON:Color { Color(hex: 0xE9967A)}
    static var SALMON:Color { Color(hex: 0xFA8072)}
    static var LIGHTSALMON:Color { Color(hex: 0xFFA07A)}
    static var ORANGERED:Color { Color(hex: 0xFF4500)}
    static var DARKORANGE:Color { Color(hex: 0xFF8C00)}
    static var GOLD:Color { Color(hex: 0xFFD700)}
    static var DARKGOLDENROD:Color { Color(hex: 0xB8860B)}
    static var GOLDENROD:Color { Color(hex: 0xDAA520)}
    static var PALEGOLDENROD:Color { Color(hex: 0xEEE8AA)}
    static var DARKKHAKI:Color { Color(hex: 0xBDB76B)}
    static var KHAKI:Color { Color(hex: 0xF0E68C)}
    static var OLIVE:Color { Color(hex: 0x808000)}
    static var YELLOWGREEN:Color { Color(hex: 0x9ACD32)}
    static var DARKOLIVEGREEN:Color { Color(hex: 0x556B2F)}
    static var OLIVEDRAB:Color { Color(hex: 0x6B8E23)}
    static var LAWNGREEN:Color { Color(hex: 0x7CFC00)}
    static var CHARTREUSE:Color { Color(hex: 0x7FFF00)}
    static var GREENYELLOW:Color { Color(hex: 0xADFF2F)}
    static var DARKGREEN:Color { Color(hex: 0x006400)}
    static var FORESTGREEN:Color { Color(hex: 0x228B22)}
    static var LIME:Color { Color(hex: 0x00FF00)}
    static var LIMEGREEN:Color { Color(hex: 0x32CD32)}
    static var PALEGREEN:Color { Color(hex: 0x98FB98)}
    static var DARKSEAGREEN:Color { Color(hex: 0x8FBC8F)}
    static var MEDIUMSPRINGGREEN:Color { Color(hex: 0x00FA9A)}
    static var SPRINGGREEN:Color { Color(hex: 0x00FF7F)}
    static var SEAGREEN:Color { Color(hex: 0x2E8B57)}
    static var MEDIUMAQUAMARINE:Color { Color(hex: 0x66CDAA)}
    static var MEDIUMSEAGREEN:Color { Color(hex: 0x3CB371)}
    static var LIGHTSEAGREEN:Color { Color(hex: 0x20B2AA)}
    static var DARKSLATEGRAY:Color { Color(hex: 0x2F4F4F)}
    static var TEAL:Color { Color(hex: 0x008080)}
    static var DARKCYAN:Color { Color(hex: 0x008B8B)}
    static var LIGHTCYAN:Color { Color(hex: 0xE0FFFF)}
    static var DARKTURQUOISE:Color { Color(hex: 0x00CED1)}
    static var TURQUOISE:Color { Color(hex: 0x40E0D0)}
    static var MEDIUMTURQUOISE:Color { Color(hex: 0x48D1CC)}
    static var PALETURQUOISE:Color { Color(hex: 0xAFEEEE)}
    static var AQUAMARINE:Color { Color(hex: 0x7FFFD4)}
    static var POWDERBLUE:Color { Color(hex: 0xB0E0E6)}
    static var CADETBLUE:Color { Color(hex: 0x5F9EA0)}
    static var STEELBLUE:Color { Color(hex: 0x4682B4)}
    static var CORNFLOWERBLUE:Color { Color(hex: 0x6495ED)}
    static var DEEPSKYBLUE:Color { Color(hex: 0x00BFFF)}
    static var DODGERBLUE:Color { Color(hex: 0x1E90FF)}
    static var SKYBLUE:Color { Color(hex: 0x87CEEB)}
    static var LIGHTSKYBLUE:Color { Color(hex: 0x87CEFA)}
    static var MIDNIGHTBLUE:Color { Color(hex: 0x191970)}
    static var NAVY:Color { Color(hex: 0x000080)}
    static var DARKBLUE:Color { Color(hex: 0x00008B)}
    static var MEDIUMBLUE:Color { Color(hex: 0x0000CD)}
    static var ROYALBLUE:Color { Color(hex: 0x4169E1)}
    static var BLUEVIOLET:Color { Color(hex: 0x8A2BE2)}
    static var INDIGO:Color { Color(hex: 0x4B0082)}
    static var DARKSLATEBLUE:Color { Color(hex: 0x483D8B)}
    static var SLATEBLUE:Color { Color(hex: 0x6A5ACD)}
    static var MEDIUMSLATEBLUE:Color { Color(hex: 0x7B68EE)}
    static var MEDIUMPURPLE:Color { Color(hex: 0x9370DB)}
    static var DARKMAGENTA:Color { Color(hex: 0x8B008B)}
    static var DARKVIOLET:Color { Color(hex: 0x9400D3)}
    static var DARKORCHID:Color { Color(hex: 0x9932CC)}
    static var MEDIUMORCHID:Color { Color(hex: 0xBA55D3)}
    static var THISTLE:Color { Color(hex: 0xD8BFD8)}
    static var PLUM:Color { Color(hex: 0xDDA0DD)}
    static var VIOLET:Color { Color(hex: 0xEE82EE)}
    static var FUCHSIA:Color { Color(hex: 0xFF00FF)}
    static var ORCHID:Color { Color(hex: 0xDA70D6)}
    static var MEDIUMVIOLETRED:Color { Color(hex: 0xC71585)}
    static var PALEVIOLETRED:Color { Color(hex: 0xDB7093)}
    static var DEEPPINK:Color { Color(hex: 0xFF1493)}
    static var LIGHTPINK:Color { Color(hex: 0xFFB6C1)}
    static var ANTIQUEWHITE:Color { Color(hex: 0xFAEBD7)}
    static var BEIGE:Color { Color(hex: 0xF5F5DC)}
    static var BISQUE:Color { Color(hex: 0xFFE4C4)}
    static var BLANCHEDALMOND:Color { Color(hex: 0xFFEBCD)}
    static var WHEAT:Color { Color(hex: 0xF5DEB3)}
    static var CORNSILK:Color { Color(hex: 0xFFF8DC)}
    static var LEMONCHIFFON:Color { Color(hex: 0xFFFACD)}
    static var LIGHTGOLDENRODYELLOW:Color { Color(hex: 0xFAFAD2)}
    static var LIGHTYELLOW:Color { Color(hex: 0xFFFFE0)}
    static var SADDLEBROWN:Color { Color(hex: 0x8B4513)}
    static var SIENNA:Color { Color(hex: 0xA0522D)}
    static var CHOCOLATE:Color { Color(hex: 0xD2691E)}
    static var PERU:Color { Color(hex: 0xCD853F)}
    static var SANDYBROWN:Color { Color(hex: 0xF4A460)}
    static var BURLYWOOD:Color { Color(hex: 0xDEB887)}
    static var TAN:Color { Color(hex: 0xD2B48C)}
    static var ROSYBROWN:Color { Color(hex: 0xBC8F8F)}
    static var MOCCASIN:Color { Color(hex: 0xFFE4B5)}
    static var NAVAJOWHITE:Color { Color(hex: 0xFFDEAD)}
    static var PEACHPUFF:Color { Color(hex: 0xFFDAB9)}
    static var MISTYROSE:Color { Color(hex: 0xFFE4E1)}
    static var LAVENDERBLUSH:Color { Color(hex: 0xFFF0F5)}
    static var LINEN:Color { Color(hex: 0xFAF0E6)}
    static var OLDLACE:Color { Color(hex: 0xFDF5E6)}
    static var PAPAYAWHIP:Color { Color(hex: 0xFFEFD5)}
    static var SEASHELL:Color { Color(hex: 0xFFF5EE)}
    static var MINTCREAM:Color { Color(hex: 0xF5FFFA)}
    static var SLATEGRAY:Color { Color(hex: 0x708090)}
    static var LIGHTSLATEGRAY:Color { Color(hex: 0x778899)}
    static var LIGHTSTEELBLUE:Color { Color(hex: 0xB0C4DE)}
    static var LAVENDER:Color { Color(hex: 0xE6E6FA)}
    static var FLORALWHITE:Color { Color(hex: 0xFFFAF0)}
    static var ALICEBLUE:Color { Color(hex: 0xF0F8FF)}
    static var GHOSTWHITE:Color { Color(hex: 0xF8F8FF)}
    static var HONEYDEW:Color { Color(hex: 0xF0FFF0)}
    static var IVORY:Color { Color(hex: 0xFFFFF0)}
    static var AZURE:Color { Color(hex: 0xF0FFFF)}
    static var SNOW:Color { Color(hex: 0xFFFAFA)}
    static var CRIMSON:Color { Color(hex: 0xDC143C)}
    static var FIREBRICK:Color { Color(hex: 0xB22222)}
    static var TOMATO:Color { Color(hex: 0xFF6347)}
    static var CORAL:Color { Color(hex: 0xFF7F50)}
    static var WHITESMOKE:Color = Color(hex: 0xF5F5F5)
    
    static subscript(name: String) -> Color {
            switch name {
            case "A": return Color.FORESTGREEN
            case "B": return Color.BURLYWOOD
            case "C": return Color.CRIMSON
            case "D": return Color.DARKORCHID
            case "E": return Color.LIME
            case "F": return Color.PERU
            case "G": return Color.GOLD
            case "H": return Color.FIREBRICK
            case "I": return Color.PALEVIOLETRED
            case "J": return Color.NAVAJOWHITE
            case "K": return Color.KHAKI
            case "L": return Color.LAVENDER
            case "M": return Color.DARKORCHID
            case "N": return Color.NAVY
            case "O": return Color.OLIVE
            case "P": return Color.PLUM
            case "Q": return Color.TURQUOISE
            case "R": return Color.ROSYBROWN
            case "S": return Color.DARKSLATEBLUE
            case "T": return Color.TOMATO
            case "U": return Color.FUCHSIA
            case "V": return Color.VIOLET
            case "W": return Color.LAWNGREEN
            case "X": return Color.DARKORANGE
            case "Y": return Color.YELLOWGREEN
            case "Z": return Color.INDIANRED
            case "Å": return Color.MIDNIGHTBLUE
            case "Ä": return Color.CORAL
            case "Ö": return Color.DEEPPINK
            case "?": return Color.SIENNA
            default: return Color.DARKSLATEBLUE
            }
    }
}
