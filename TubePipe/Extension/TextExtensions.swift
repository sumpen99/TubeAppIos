//
//  TextExtensions.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI

extension Text{
    
    func largeTitle(color:Color = Color.black) -> some View{
        self.font(.largeTitle)
            .bold()
            .foregroundColor(color)
            .hLeading()
    }
    
    func avatar(initial:String) -> some View{
         self.font(.headline)
            .padding()
            .background{
                Circle().fill(Color[initial])
            }
            .foregroundColor(.white)
    }
    
    func noDataBackground() -> some View{
        self.hLeading()
        .padding()
        .foregroundColor(Color.placeholderText)
        .background(
            ZStack{
                RoundedRectangle(cornerRadius: 8).fill(Color.white)
            }
        )
        .padding()
    }
    
    func noDataBackgroundNoPadding() -> some View{
        self.hCenter()
        .padding()
        .foregroundColor(Color.darkGray)
    }
    
    func lightCaption() -> some View{
        self.font(.caption).fontWeight(.light).foregroundColor(.gray)
    }
    
    func preferedBody() -> some View{
        self.font(Font(UIFont.preferredFont(forTextStyle: .body))).foregroundColor(Color.systemGray)
    }
    
    func settingsText() -> some View{
        self.multilineTextAlignment(.center)
        .keyboardType(UIKeyboardType.numberPad)
        .foregroundColor(Color.black)
        .textFieldStyle(RoundedBorderTextFieldStyle())
    }
    
    func listSectionHeader(color:Color = .darkGray) -> some View{
        self.foregroundColor(color).bold()
    }
    
    func profileSectionHeader() -> some View{
        self.foregroundColor(.black).bold().font(.headline)
    }
    
    func listSectionFooter(color:Color = .systemGray) -> some View{
        self.foregroundColor(color).italic()
    }
    
    func leadingSectionHeader(color:Color = .black) -> some View{
        self.foregroundColor(color).bold().hLeading()
    }
    
    func bubbleText() -> some View{
        self
        .lineLimit(nil)
        .multilineTextAlignment(.leading)
        .font(.callout)
        .foregroundColor(Color.white)
    }
    
}

extension TextField{
    
    func preferedEmailField(textColor:Color = Color.GHOSTWHITE) -> some View{
        self
            .font(Font(UIFont.preferredFont(forTextStyle: .body)))
            .foregroundColor(textColor)
            .keyboardType(.emailAddress)
            .padding([.bottom,.top],10)
            .removePredictiveSuggestions()
            .accentColor(.black)
            .background(RoundedRectangle(cornerRadius: 5).fill(Color.clear))
    }
    
    func preferedSearchField() -> some View{
        self
            .font(Font(UIFont.preferredFont(forTextStyle: .title3)))
            .keyboardType(UIKeyboardType.asciiCapable)
            .removePredictiveSuggestions()
            .accentColor(.black)
            .padding(5.0)
    }
    
    func preferedSettingsField() -> some View{
        self
            .multilineTextAlignment(.center)
            .font(Font(UIFont.preferredFont(forTextStyle: .title1)))
            .keyboardType(UIKeyboardType.numberPad)
            .removePredictiveSuggestions()
            .background(RoundedRectangle(cornerRadius: 5).fill(Color.tertiarySystemFill))
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(lineWidth: 1)
            )
            .foregroundColor(Color.GHOSTWHITE)
            .accentColor(.black)
    }
    
    func preferedProfileSettingsField() -> some View{
        self
            .padding(5)
            .multilineTextAlignment(.leading)
            .lineLimit(1)
            .keyboardType(UIKeyboardType.asciiCapable)
            .removePredictiveSuggestions()
            .overlay(
                Rectangle().frame(height: 1.0).vBottom().foregroundColor(Color.tertiaryLabel)
            )
            .accentColor(.black)
            
    }
    
    func preferedDocumentField() -> some View{
        self
            .multilineTextAlignment(.leading)
            .font(Font(UIFont.preferredFont(forTextStyle: .body)))
            .keyboardType(UIKeyboardType.asciiCapable)
            .removePredictiveSuggestions()
            .foregroundColor(Color.black)
            .accentColor(.black)
            .hLeading()
    }
    
    func preferedTubeSettingsField() -> some View{
        self
            .multilineTextAlignment(.center)
            .font(Font(UIFont.preferredFont(forTextStyle: .title1)))
            .keyboardType(UIKeyboardType.numberPad)
            .removePredictiveSuggestions()
            .background(RoundedRectangle(cornerRadius: 5).fill(Color.GHOSTWHITE))
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(lineWidth: 1)
            )
            .foregroundColor(Color.black)
            .accentColor(.black)
    }
   
}

extension SecureField{
    func preferedSecureField() -> some View{
        self.padding([.top,.bottom],10).textContentType(.oneTimeCode).foregroundColor(Color.black).accentColor(.black)
    }
}
