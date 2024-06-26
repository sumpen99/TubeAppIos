//
//  CheckboxToggleStyle.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-07-18.
//

import SwiftUI
struct CheckboxStyle: ToggleStyle {
    let alignLabelLeft:Bool
    let labelIsOnColor:Color
    @ViewBuilder
    func makeBody(configuration: Self.Configuration) -> some View {
        if alignLabelLeft{
            HStack{
                configuration.label.foregroundStyle(Color.black).font(.caption)
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color.black)
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .onTapGesture {
                        configuration.isOn.toggle()
                    }
            }
        }
        else{
            HStack{
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color.black)
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .onTapGesture {
                        configuration.isOn.toggle()
                    }
                configuration.label.foregroundStyle(configuration.isOn ? labelIsOnColor : Color.systemGray).font(.caption)
            }
        }
    }
}

struct CapsuleCheckboxStyle: ToggleStyle {
    let alignLabelLeft:Bool
    
    @ViewBuilder
    func makeBody(configuration: Self.Configuration) -> some View {
        if alignLabelLeft{
            HStack{
                configuration.label
                Spacer()
                Capsule()
                .fill(configuration.isOn ? Color.black : Color.tertiaryLabel)
                .animation(.default, value: configuration.isOn)
                .frame(width: 48, height: 30)
                .overlay(alignment: configuration.isOn ? .trailing : .leading){
                    filledCircleWithColor()
                }
                .onTapGesture {
                    withAnimation{
                        configuration.isOn.toggle()
                    }
                }
            }
            
        }
        else{
            HStack{
                Capsule()
                .fill(configuration.isOn ? Color.black : Color.tertiaryLabel)
                .animation(.default, value: configuration.isOn)
                .frame(width: 48, height: 30)
                .overlay(alignment: configuration.isOn ? .trailing : .leading){
                    Circle()
                        .fill(Color.white)
                        .frame(width: 26, height: 26)
                        .padding(2)
                }
                .onTapGesture {
                    withAnimation{
                        configuration.isOn.toggle()
                    }
                }
                Spacer()
                configuration.label
            }
        }
        
    }
}

struct XMarkCheckboxStyle: ToggleStyle {
    let alignLabelLeft:Bool
    
    @ViewBuilder
    func makeBody(configuration: Self.Configuration) -> some View {
        if alignLabelLeft{
            HStack{
                configuration.label.foregroundStyle(configuration.isOn ? Color.backgroundPrimary : Color.tertiaryLabel).font(.caption)
                Image(systemName: configuration.isOn ? "xmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(configuration.isOn ? Color.systemRed : .gray)
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .onTapGesture {
                        withAnimation{
                            configuration.isOn.toggle()
                        }
                    }
            }
        }
        else{
            HStack{
                Image(systemName: configuration.isOn ? "xmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(configuration.isOn ? Color.systemRed : .gray)
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .onTapGesture {
                        withAnimation{
                            configuration.isOn.toggle()
                        }
                    }
                configuration.label.foregroundStyle(configuration.isOn ? Color.backgroundPrimary : Color.tertiaryLabel).font(.caption)
            }
        }
       
 
    }
}
