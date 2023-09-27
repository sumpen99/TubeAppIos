//
//  TubeSettingsView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-19.
//

import SwiftUI

enum SettingsHeader:String,CaseIterable{
    case BUILD = "Build tube"
    case INFO = "Drawoption"
}

enum SettingsOption:String,CaseIterable{
    case DIMENSION = "Dimension"
    case SEGMENT = "Segment"
    case STEEL = "Steel"
    case DEGREES = "Degrees"
    case RADIUS = "Radius"
    case LENA = "Len A"
    case LENB = "Len B"
}

enum DrawOption{
    case LABELSDEGREES
    case LABELSLENGTH
    case CUTLINES
    case CENTERLINE
    case DIAGONALLINE
    case MIDPOINT
    case BOUNDINGBOX
    case TUBE_CENTERLINE
    case FULLCIRCLE
    case KEEP_DEGREES
    case ADD_ONE_HUNDRED
    case AUTO_ALIGN
    case ALLOW_SHARING
    case ALL_SETTINGS_OPTIONS
    case FULL_SIZE_MUFF
    case SCALED_SIZE_MUFF
    case SHOW_WHOLE_MUFF
    case SHOW_SPLIT_MUFF
    case DRAW_FILLED_MUFF
    case DRAW_LINED_MUFF
    case DRAW_SEE_THROUGH_MUFF
    case ALL_OPTIONS
    
}

extension DrawOption{
    static func indexOf(op:DrawOption) -> Int{
        switch op{
        case .LABELSDEGREES:            return 0
        case .LABELSLENGTH:             return 1
        case .CUTLINES:                 return 2
        case .CENTERLINE:               return 3
        case .DIAGONALLINE:             return 4
        case .MIDPOINT:                 return 5
        case .BOUNDINGBOX:              return 6
        case .TUBE_CENTERLINE:          return 7
        case .FULLCIRCLE:               return 8
        case .KEEP_DEGREES:             return 9
        case .ADD_ONE_HUNDRED:          return 10
        case .AUTO_ALIGN:               return 11
        case .ALLOW_SHARING:            return 12
        case .ALL_SETTINGS_OPTIONS:     return 13
        case .FULL_SIZE_MUFF:           return 14
        case .SCALED_SIZE_MUFF:         return 15
        case .SHOW_WHOLE_MUFF:          return 16
        case .SHOW_SPLIT_MUFF:          return 17
        case .DRAW_FILLED_MUFF:         return 18
        case .DRAW_LINED_MUFF:          return 19
        case .DRAW_SEE_THROUGH_MUFF:    return 20
        case .ALL_OPTIONS:              return 21
        }
        
    }
}

struct TubeSettingsVar{
    var categoriesIsShowing:Bool = false
    var alignmentIsShowing:Bool = false
    var settingsHeader:SettingsHeader = .BUILD
    var settingsOption:SettingsOption = .DEGREES
    var orientation = UIDeviceOrientation.unknown
}

struct TubeSettingsView:View{
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tubeViewModel: TubeViewModel
    @State var tsVar:TubeSettingsVar = TubeSettingsVar()
    @Namespace var animation
    
    private var settingsHeader:[SettingsHeader] = [
        SettingsHeader.BUILD,
        SettingsHeader.INFO
    ]
    
    private var settingsItem:[SettingsOption] = [
        SettingsOption.DEGREES,
        SettingsOption.SEGMENT,
        SettingsOption.RADIUS,
        SettingsOption.DIMENSION,
        SettingsOption.STEEL,
        SettingsOption.LENA,
        SettingsOption.LENB,
    ]
    
    //MARK: - HORIZONTAL MENU-SCROLLVIEWS
    var settingsHeaderMenuList:  some View{
        ZStack{
            HStack{
                ScrollView(.horizontal){
                    LazyHStack(alignment: .top, spacing: 10, pinnedViews: [.sectionHeaders]){
                        ForEach(settingsHeader, id: \.self) { header in
                            settingsHeaderCell(header)
                       }
                    }
                    
                }
                .scrollIndicators(.never)
                Spacer()
                Button("\(Image(systemName: BACK_BUTTON_PRIMARY))", action: closeView)
            }
            .padding([.leading,.trailing,.top])
            
        }
        .frame(height:MENU_HEIGHT)
    }
    
    var settingsItemMenuList:some View{
        ScrollView(.horizontal){
            LazyHStack(alignment: .center, spacing: 10, pinnedViews: [.sectionHeaders]){
                ForEach(settingsItem, id: \.self) { setting in
                    settingsOptionCell(setting)
               }
            }
            .padding()
        }
        .frame(height:MENU_HEIGHT)
        .scrollIndicators(.never)
    }
    
    //MARK: - MENU CELLS
    func settingsHeaderCell(_ setting:SettingsHeader) -> some View{
        return Text(setting.rawValue)
        .font(.headline)
        .frame(height: 33)
        .background(
             ZStack{
                 if setting == tsVar.settingsHeader{
                     Color.black
                     .frame(height: 1)
                     .offset(y: 14)
                     .matchedGeometryEffect(id: "CURRENTHEADER", in: animation)
                 }
             }
        )
        .foregroundStyle(setting == tsVar.settingsHeader ? .primary : .tertiary)
        .onTapGesture {
            withAnimation{
                tsVar.settingsHeader = setting
            }
        }
    }
    
    func settingsOptionCell(_ setting:SettingsOption) -> some View{
        return Text(setting.rawValue)
        .font(.headline)
        .frame(width: 100, height: 33)
        .bold()
        .background(
             ZStack{
                 if setting == tsVar.settingsOption{
                     RoundedRectangle(cornerRadius: 8).fill(Color.systemBlue).opacity(0.1)
                     .matchedGeometryEffect(id: "CURRENTSETTING", in: animation)
                 }
             }
        )
        .foregroundStyle(setting == tsVar.settingsOption ? .primary : .tertiary)
        .onTapGesture {
            withAnimation{
                tsVar.settingsOption = setting
            }
        }
    }
    
    //MARK: - SLIDERS
    var alignment: some View{
        Section(header: Text("Align Center").foregroundColor(Color.systemGray)) {
            SliderSection(sliderValue: $tubeViewModel.settingsVar.center,
                          minValue: -CGFloat.infinity,
                          maxValue: CGFloat.infinity,
                          textEnding: "",
                          textfieldValue: "",
                          isNotAlignmentSection: false)
        }
    }
 
    func getCategorieCell(_ item:SettingsOption) -> some View{
        return Section(header: Text(item.rawValue).foregroundColor(Color.systemGray)) {
                switch item{
                case .DEGREES:
                    VStack{
                        SliderSection(sliderValue: $tubeViewModel.settingsVar.grader,
                                      minValue: 0.0,
                                      maxValue: 360.0,
                                      textEnding: "°",
                                      textfieldValue: "\(Int(tubeViewModel.settingsVar.grader))")
                    }
                    
                case .DIMENSION:
                    SliderSection(sliderValue: $tubeViewModel.settingsVar.dimension,
                                  minValue: 1.0,
                                  maxValue: CGFloat(tubeViewModel.userDefaultSettingsVar.preferredSetting.dimension),
                                  textEnding: "mm",
                                  textfieldValue: "\(Int(tubeViewModel.settingsVar.dimension))")
                case .SEGMENT:
                    SliderSection(sliderValue: $tubeViewModel.settingsVar.segment,
                                  minValue: 0.0,
                                  maxValue: CGFloat(tubeViewModel.userDefaultSettingsVar.preferredSetting.segment),
                                  textEnding: "st",
                                  textfieldValue: "\(Int(tubeViewModel.settingsVar.segment))")
                case .STEEL:
                    SliderSection(sliderValue: $tubeViewModel.settingsVar.steel,
                                  minValue: 1.0,
                                  maxValue: CGFloat(tubeViewModel.userDefaultSettingsVar.preferredSetting.dimension),
                                  textEnding: "mm",
                                  textfieldValue: "\(Int(tubeViewModel.settingsVar.steel))")
                case .RADIUS:
                    SliderSection(sliderValue: $tubeViewModel.settingsVar.radie,
                                  minValue: 1.0,
                                  maxValue: CGFloat(tubeViewModel.userDefaultSettingsVar.preferredSetting.radius),
                                  textEnding: "mm",
                                  textfieldValue: "\(Int(tubeViewModel.settingsVar.radie))")
                case .LENA:
                    SliderSection(sliderValue: $tubeViewModel.settingsVar.lena,
                                  minValue: 1.0,
                                  maxValue: CGFloat(tubeViewModel.userDefaultSettingsVar.preferredSetting.length),
                                  textEnding: "mm",
                                  textfieldValue: "\(Int(tubeViewModel.settingsVar.lena))")
                case .LENB:
                    SliderSection(sliderValue: $tubeViewModel.settingsVar.lenb,
                                  minValue: 1.0,
                                  maxValue: CGFloat(tubeViewModel.userDefaultSettingsVar.preferredSetting.length),
                                  textEnding: "mm",
                                  textfieldValue: "\(Int(tubeViewModel.settingsVar.lenb))")
                }
        }
    }
    
    //MARK: - SWITCHES
    @ViewBuilder
    func getSwitchSection(header:String,index:Int) -> some View{
        VStack{
            HStack{
                filledCircleWithColor(.black,size: 10.0)
                Text(header).font(.body).foregroundColor(.black)
                Spacer()
                Toggle(isOn: self.$tubeViewModel.userDefaultSettingsVar.drawOptions[index]){}
                    .toggleStyle(CheckboxStyle(alignLabelLeft: true,labelIsOnColor:.black))
            }
            .hLeading()
            .padding()
            Divider()
        }
    }
    
    func getSwitchCutAngles() -> some View{
        Section(header: Text("Cut Angles").foregroundColor(Color.systemGray)) {
            VStack{
                HStack{
                    Toggle(isOn:!self.$tubeViewModel.userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .KEEP_DEGREES)]){
                        Text("Adjust")
                    }.disabled(tubeViewModel.settingsVar.segment < 2)
                    .toggleStyle(CheckboxStyle(alignLabelLeft: false,labelIsOnColor:.black))
                    Spacer()
                    Toggle(isOn: self.$tubeViewModel.userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .KEEP_DEGREES)]){
                        Text("Same")
                    }.disabled(tubeViewModel.settingsVar.segment < 2)
                    .toggleStyle(CheckboxStyle(alignLabelLeft: true,labelIsOnColor:.black))
                    .onChange(of: self.tubeViewModel.userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .KEEP_DEGREES)]){ value in
                        tubeViewModel.rebuild()
                        tubeViewModel.settingsVar.redraw.toggle()
                    }
                }
                .hLeading()
                .padding([.leading,.trailing])
            }
        }
        .opacity(tubeViewModel.settingsVar.segment < 2 ? 0.2 : 1.0)
    }
    
    @ViewBuilder
    func getSwitchAutoAlign() -> some View{
        if tubeViewModel.userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .AUTO_ALIGN)]{
            Section(header: Text("Automatic Align").foregroundColor(Color.systemGray)) {
                VStack{
                    HStack{
                        Toggle(isOn:!self.$tubeViewModel.userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .AUTO_ALIGN)]){
                            Text("No")
                        }
                        .toggleStyle(XMarkCheckboxStyle(alignLabelLeft: false))
                        Spacer()
                        Toggle(isOn: self.$tubeViewModel.userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .AUTO_ALIGN)]){
                            Text("Yes")
                        }
                        .toggleStyle(CheckboxStyle(alignLabelLeft: true,labelIsOnColor:.black))
                        .onChange(of: self.tubeViewModel.userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .AUTO_ALIGN)]){ value in
                            tubeViewModel.rebuild()
                            tubeViewModel.settingsVar.redraw.toggle()
                        }
                    }
                    .hLeading()
                    .padding([.leading,.trailing])
                }
            }
        }
        else{
            Section(header: HStack{
                Button(action: {
                    withAnimation{
                        self.tubeViewModel.userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .AUTO_ALIGN)].toggle()
                        self.tubeViewModel.rebuild()
                    }
                }){
                    Text("Automatic align").foregroundColor(Color.systemBlue)
                }
            }.hCenter()){
                SliderSection(sliderValue: $tubeViewModel.settingsVar.center,
                              minValue: -CGFloat.infinity,
                              maxValue: CGFloat.infinity,
                              textEnding: "",
                              textfieldValue: "",
                              isNotAlignmentSection: false)
            }
        }
    }
    
    func getSwitchAddHundred() -> some View{
        Section(header: Text("Overlap").foregroundColor(Color.systemGray)) {
            VStack{
                HStack{
                    Toggle(isOn:!self.$tubeViewModel.userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .ADD_ONE_HUNDRED)]){
                        Text("No")
                    }
                    .toggleStyle(XMarkCheckboxStyle(alignLabelLeft: false))
                    Spacer()
                    Toggle(isOn: self.$tubeViewModel.userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .ADD_ONE_HUNDRED)]){
                        Text("Yes")
                    }
                    .toggleStyle(CheckboxStyle(alignLabelLeft: true,labelIsOnColor:.black))
                    .onChange(of: self.tubeViewModel.userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .ADD_ONE_HUNDRED)]){ value in
                        tubeViewModel.rebuild()
                        tubeViewModel.settingsVar.redraw.toggle()
                    }
                }
                .hLeading()
                .padding([.leading,.trailing])
            }
        }
    }
    @ViewBuilder
    func getSwitchSectionBase(index:Int) -> some View{
        switch index{
        case DrawOption.indexOf(op: .LABELSDEGREES):
            getSwitchSection(header: "Labels Degree",
                             index: DrawOption.indexOf(op: .LABELSDEGREES))
        case DrawOption.indexOf(op: .LABELSLENGTH):
            getSwitchSection(header: "Labels Length",
                             index: DrawOption.indexOf(op: .LABELSLENGTH))
        case DrawOption.indexOf(op: .CUTLINES):
            getSwitchSection(header: "Cutlines",
                             index: DrawOption.indexOf(op: .CUTLINES))
        case DrawOption.indexOf(op: .CENTERLINE):
            getSwitchSection(header: "Center triangle",
                             index: DrawOption.indexOf(op: .CENTERLINE))
        case DrawOption.indexOf(op: .DIAGONALLINE):
            getSwitchSection(header: "Diagonal line",
                             index: DrawOption.indexOf(op: .DIAGONALLINE))
        case DrawOption.indexOf(op: .MIDPOINT):
            getSwitchSection(header: "Midpoint",
                             index: DrawOption.indexOf(op: .MIDPOINT))
        case DrawOption.indexOf(op: .BOUNDINGBOX):
            getSwitchSection(header: "Boundingbox",
                             index: DrawOption.indexOf(op: .BOUNDINGBOX))
        case DrawOption.indexOf(op: .TUBE_CENTERLINE):
            getSwitchSection(header: "Muff centerline",
                             index: DrawOption.indexOf(op: .TUBE_CENTERLINE))
        case DrawOption.indexOf(op: .FULLCIRCLE):
            getSwitchSection(header: "Full circle",
                             index: DrawOption.indexOf(op: .FULLCIRCLE))
        default: EmptyView()
        }
    }
        
    // MARK: - PAGES
    @ViewBuilder
    func getCurrentPage(_ item:SettingsHeader) -> some View{
        switch item{
        case .BUILD:    pageOne
        case .INFO:     pageTwo
        }
    }
    
    // PAGE ONE - BUILD TUBE
    var pageOne:some View{
        VStack(spacing:10){
            settingsItemMenuList
            Divider()
            ScrollView{
                VStack(spacing:10){
                    getCategorieCell(tsVar.settingsOption)
                    Divider()
                    getSwitchAutoAlign()
                    Divider()
                    getSwitchAddHundred()
                    Divider()
                    getSwitchCutAngles()
                    Divider()
                    bottomExtraPadding
                }
            }
        }
    }
        
    // PAGE TWO - INFO
    var pageTwo:some View{
        ScrollView{
            LazyVStack{
                ForEach(0..<DrawOption.indexOf(op: .ALL_SETTINGS_OPTIONS),id: \.self){ index in
                    getSwitchSectionBase(index: index)
                }
                bottomExtraPadding
             }
            .padding()
        }
        
    }
    
    //MARK: - BODY
    var body: some View{
        //Color.white.opacity(0.3).background(BackgroundClearView())
        VStack(spacing:10){
            settingsHeaderMenuList
            Divider()
            getCurrentPage(tsVar.settingsHeader)
        }
        .modifier(HalfSheetModifier())
        .onTapGesture{ endTextEditing() }
        .onDisappear(){
            if tubeViewModel.userDefaultSettingsVar.drawingHasChanged{
                tubeViewModel.saveUserDefaultDrawingValues()
            }
        }
    }
    
    //MARK: - HELPER
    func closeView(){
        dismiss()
    }
}
