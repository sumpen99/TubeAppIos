//
//  ViewExtensions.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI

extension View{
    
    func badge(value: String?) -> some View {
        modifier(BadgeViewModifier(text: value))
    }
        
    @ViewBuilder func `if`<Result: View>(_ condition: Bool, closure: @escaping (Self) -> Result) -> some View {
        if condition {
            closure(self)
        } else {
            self
        }
    }
    
    func sectionText(font:Font = .body,color:Color = Color.black) -> some View{
        self
        .foregroundColor(color)
        .font(font)
        .fontWeight(.bold)
        .lineLimit(1)
        .hLeading()
    }
    func sectionTextSecondary(color:Color = Color.GHOSTWHITE) -> some View{
        self
        .foregroundColor(color)
        .font(.body)
        .hLeading()
    }
    
    func filledRoundedBackgroundWithBorder(_ background:Color = .white,border:Color = .systemGray,radius:CGFloat = 5) -> some View{
        self.background{
            RoundedRectangle(cornerRadius: radius)
                .fill(background.shadow(.drop(color: .black, radius: 1)))
        }
        .overlay(
            RoundedRectangle(cornerRadius: 5)
            .stroke(lineWidth: 2)
            .foregroundColor(border)
        )
    }
    
    func hFill() -> some View{
        self.frame(minWidth: 0, maxWidth: .infinity)
    }
    
    func hLeading() -> some View{
        self.frame(maxWidth: .infinity,alignment: .leading)
    }
    
    func hTrailing() -> some View{
        self.frame(maxWidth: .infinity,alignment: .trailing)
    }
    
    func hCenter() -> some View{
        self.frame(maxWidth: .infinity,alignment: .center)
    }
    
    func vTop() -> some View{
        self.frame(maxHeight: .infinity,alignment: .top)
    }
    
    func vBottom() -> some View{
        self.frame(maxHeight: .infinity,alignment: .bottom)
    }
    
    func vCenter() -> some View{
        self.frame(maxHeight: .infinity,alignment: .center)
    }
    
    func trailingHeadline() -> some View{
        self.font(.headline).padding(.trailing)
    }
    
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(DeviceShakeViewModifier(action: action))
    }
    
    func formButtonDesign(width:CGFloat,backgroundColor:Color) -> some View{
        modifier(FormButtonModifier(width: width, backgroundColor: backgroundColor))
    }
    
    func sectionHeader() -> some View{
        modifier(SectionHeaderModifier())
    }
    
    func fillSection() -> some View{
        self.modifier(FillFormModifier())
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorners(radius: radius, corners: corners) )
    }
    
    func onConditionalAlert(actionPrimary:@escaping (()-> Void),
                        actionSecondary:@escaping (()-> Void)) -> Alert{
        return Alert(
                title: Text(ALERT_TITLE),
                message: Text(ALERT_MESSAGE),
                primaryButton: .default(Text(ALERT_LABEL_OK), action: { actionPrimary() }),
                secondaryButton: .cancel(Text(ALERT_LABEL_CANCEL), action: { actionSecondary() } )
        )
    }
    
    func onResultAlert(action:(()-> Void)? = nil) -> Alert{
        return Alert(
                title: Text(ALERT_TITLE),
                message: Text(ALERT_MESSAGE),
                dismissButton: .cancel(Text(ALERT_LABEL_OK), action: { action?() } )
        )
    }
    
    func onPrivacyAlert(actionPrimary:@escaping (()-> Void),
                        actionSecondary:@escaping (()-> Void)) -> Alert{
        return Alert(
                title: Text(ALERT_PRIVACY_TITLE),
                message: Text(ALERT_PRIVACY_MESSAGE),
                primaryButton: .destructive(Text(ALERT_LABEL_OK), action: { actionPrimary() }),
                secondaryButton: .cancel(Text(ALERT_LABEL_CANCEL), action: { actionSecondary() } )
        )
    }
    
    func onAlertWithOkAction(actionPrimary:@escaping (()-> Void)) -> Alert{
        return Alert(
                title: Text(ALERT_TITLE),
                message: Text(ALERT_MESSAGE),
                primaryButton: .destructive(Text(ALERT_LABEL_OK), action: { actionPrimary() }),
                secondaryButton: .cancel(Text(ALERT_LABEL_CANCEL), action: { })
        )
    }
    
    func placeholder<Content: View>(
            when shouldShow: Bool,
            alignment: Alignment = .leading,
            @ViewBuilder placeholder: () -> Content) -> some View {

            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
    }
    
    func placeholder(
            _ text: String,
            when shouldShow: Bool,
            alignment: Alignment = .leading) -> some View {
                
            placeholder(when: shouldShow, alignment: alignment) { Text(text).preferedBody() }
    }
    
    func fieldFirstResponder(action: @escaping () -> Void) -> some View{
        self.contentShape(Rectangle())
        .onTapGesture{
            action()
        }
    }
    
    func endTextEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
    
    func activateTextEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
    
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
    
    func halfSheetBackgroundStyle() -> some View{
        self.background{
            halfSheetBackgroundColor
        }
    }
    
    func roundedBorder() -> some View{
        self.padding()
            .background{
                RoundedRectangle(cornerRadius: 5).stroke(Color.black)
            }  
    }
    
    func profileListRow() -> some View{
        self.fullListWidthSeperator().listRowBackground(Color.lightText)
    }
    
    func fullListWidthSeperator() -> some View{
        self.alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
            return 0
        }
    }
    
    func toolbarFontAndPadding(_ font:Font = .title2) -> some View{
        self.padding([.top,.bottom]).font(font)
    }
    
    func hiddenBackButtonWithCustomTitle(_ title:String = "",color:Color = Color.accentColor) -> some View{
        self.navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton(title: title,color: color)
                .toolbarFontAndPadding()
            }
        }
    }
    
    func calendarSectionEdgeInsets() -> some View{
        self.listRowInsets(EdgeInsets(
            top: 5,
            leading: 0,
            bottom: 5,
            trailing: 0))
    }
    
    func persistent() -> some View {
        PersistentContentView { self }
    }
    
    func toastView(toast: Binding<Toast?>) -> some View {
        self.modifier(ToastModifier(toast: toast))
    }
    
    func closeAfterToast(isSuccess:Bool,msg:String,toast:inout Toast?,action:(() -> Void)? = nil){
        if(isSuccess){ toast = Toast(style: .success, message: msg) }
        else{ toast = Toast(style: .error, message: "Operation failed!") }
        DispatchQueue.main.asyncAfter(deadline: .now() + TOAST_DURATION){
            action?()
        }
    }
    
    
    
}

func buttonAsNavigationLink(title:String,systemImage:String) -> some View{
    return HStack{
        Label(title, systemImage: systemImage).foregroundColor(.black).hLeading()
        Spacer()
        Image(systemName: "chevron.right").foregroundColor(.tertiaryLabel).font(.subheadline).bold()
    }
}

func backButton(title:String = "Back",action:@escaping ()->Void) -> some View{
    return HStack{
        Button(action:action) {
            HStack(spacing: 5){
                Image(systemName: "chevron.left").bold()
                Text(title)
            }
            .foregroundColor(Color.systemBlue)
        }
    }
}

var splitLine: some View{
    HStack{
        Rectangle().fill(Color.black).frame(height: 1)
    }
}

func vSplitLineWithColor(_ color:Color,thickness:CGFloat = 1.0) -> some View{
    HStack{
        Rectangle().fill(color).frame(height: thickness)
    }
    .hLeading()
}

func filledCircleWithColor(_ color:Color = .white,
                           size:CGFloat = 26.0,
                           padding:CGFloat = 2.0) -> some View{
    Circle()
    .fill(color)
    .frame(width: size, height: size)
    .padding(padding)
}

func listDotWithImage(_ name:String = "gearshape",
                           padding:CGFloat = 2.0) -> some View{
    Image(systemName: name)
    .padding(padding)
}

func hSplitLine(color:Color) -> some View{
    HStack{
        Rectangle().fill(color).frame(height: 1)
    }
}

var bottomExtraPadding: some View{
    ZStack{
        halfSheetBackgroundColor
    }
    .frame(height:MENU_HEIGHT)
}

var clearSpaceAtBottom: some View{
    ZStack{
        Color.clear
    }
    .frame(height:MENU_HEIGHT)
}

func actionSheetWithCancel(_ dat:(title:String,message:String,cancel:String)) -> ActionSheet{
    return ActionSheet(title: Text(dat.title),
                       message: Text(dat.message),
                       buttons: [.cancel(Text(dat.cancel))])
}

func actionSheetDefault() -> ActionSheet{
    return ActionSheet(title: Text("Ooops!"), message: Text("Sorry for the inconvenience but we experienced an unexpected error..."), buttons: [
        .cancel(Text("Ok"))
    ])
}
