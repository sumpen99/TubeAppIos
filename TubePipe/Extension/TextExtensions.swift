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
            .foregroundStyle(color)
            .hLeading()
    }
    
    func avatar(initial:String) -> some View{
         self.font(.headline)
            .padding()
            .background{
                Circle().fill(Color[initial])
            }
            .foregroundStyle(.white)
    }
    
    func noDataBackground() -> some View{
        self.hLeading()
        .padding()
        .foregroundStyle(Color.placeholderText)
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
        .foregroundStyle(Color.darkGray)
    }
    
    func lightCaption() -> some View{
        self.font(.caption).fontWeight(.light).foregroundStyle(.gray)
    }
    
    func preferedBody() -> some View{
        self.font(Font(UIFont.preferredFont(forTextStyle: .body))).foregroundStyle(Color.systemGray)
    }
    
    func settingsText() -> some View{
        self.multilineTextAlignment(.center)
        .keyboardType(UIKeyboardType.numberPad)
        .foregroundStyle(Color.black)
        .textFieldStyle(RoundedBorderTextFieldStyle())
    }
    
    func listSectionHeader(color:Color = .black) -> some View{
        self.foregroundStyle(color).bold()
    }
    
    func profileSectionHeader() -> some View{
        self.foregroundStyle(.black).bold().font(.headline)
    }
    
    func listSectionFooter(color:Color = .systemGray) -> some View{
        self.foregroundStyle(color).italic()
    }
    
    func leadingSectionHeader(color:Color = .black) -> some View{
        self.foregroundStyle(color).bold().hLeading()
    }
    
    func bubbleText() -> some View{
        self
        .lineLimit(nil)
        .multilineTextAlignment(.leading)
        .font(.callout)
        .foregroundStyle(Color.white)
    }
    
}

extension TextField{
    
    func removePredictiveSuggestions(keyBoardType:UIKeyboardType) -> some View {
        self.keyboardType(keyBoardType)
            .disableAutocorrection(true)
            .autocapitalization(.none)
    }
    
    func preferedEmailField(textColor:Color) -> some View{
        self.removePredictiveSuggestions(keyBoardType: .asciiCapable)
            .font(Font(UIFont.preferredFont(forTextStyle: .headline)))
            .foregroundStyle(textColor)
            .padding([.bottom,.top],10)
            .accentColor(.black)
    }
    
    func preferedSearchField() -> some View{
        self.removePredictiveSuggestions(keyBoardType: .asciiCapable)
            .font(Font(UIFont.preferredFont(forTextStyle: .title2)))
            .accentColor(.black)
            .padding(5.0)
    }
    
    func preferedSettingsField() -> some View{
        self.removePredictiveSuggestions(keyBoardType: .numberPad)
            .multilineTextAlignment(.center)
            .font(Font(UIFont.preferredFont(forTextStyle: .title1)))
            .background(RoundedRectangle(cornerRadius: 5).fill(Color.tertiarySystemFill))
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(lineWidth: 1)
            )
            .foregroundStyle(Color.GHOSTWHITE)
            .accentColor(.black)
    }
    
    func preferedProfileSettingsField() -> some View{
        self.removePredictiveSuggestions(keyBoardType: .asciiCapable)
            .multilineTextAlignment(.leading)
            .lineLimit(1)
            .padding(5)
            .overlay(
                Rectangle().frame(height: 1.0).vBottom().foregroundStyle(Color.tertiaryLabel)
            )
            .accentColor(.black)
            
    }
    
    func preferedDocumentField() -> some View{
        self.removePredictiveSuggestions(keyBoardType: .asciiCapable)
            .multilineTextAlignment(.leading)
            .font(Font(UIFont.preferredFont(forTextStyle: .body)))
            .foregroundStyle(Color.black)
            .accentColor(.black)
            .hLeading()
    }
    
    func preferedTubeSettingsField() -> some View{
        self.removePredictiveSuggestions(keyBoardType: .numberPad)
            .multilineTextAlignment(.center)
            .font(Font(UIFont.preferredFont(forTextStyle: .title1)))
            .background(RoundedRectangle(cornerRadius: 5).fill(Color.GHOSTWHITE))
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(lineWidth: 1)
            )
            .foregroundStyle(Color.black)
            .accentColor(.black)
    }
   
}

extension SecureField{
    func preferedSecureField() -> some View{
        self.textContentType(.oneTimeCode)
            .keyboardType(.asciiCapable)
            .font(Font(UIFont.preferredFont(forTextStyle: .headline)))
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .foregroundStyle(Color.black)
            .padding([.top,.bottom],10)
            .accentColor(.black)
    }
}
