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
    case SHOW_WORLD_AXIS
    case SHOW_STEEL
    case SHOW_MUFF
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
        case .SHOW_WORLD_AXIS:          return 21
        case .SHOW_STEEL:               return 22
        case .SHOW_MUFF:                return 23
        case .ALL_OPTIONS:              return 24
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
        HStack{
            ScrollView(.horizontal){
                LazyHStack(alignment: .top, spacing: 30, pinnedViews: [.sectionHeaders]){
                    ForEach(settingsHeader, id: \.self) { header in
                        settingsHeaderCell(header)
                   }
                }
            }
            .scrollIndicators(.never)
        }
        .hCenter()
        .padding([.leading,.trailing,.top])
        .frame(height:MENU_HEIGHT)
    }
    
    var settingsItemMenuList:some View{
        ScrollView(.horizontal){
            LazyHStack(alignment: .center, spacing: 20, pinnedViews: [.sectionHeaders]){
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
        .bold()
        .frame(height: 33)
        .foregroundColor(setting == tsVar.settingsHeader ? Color.black : Color.tertiaryLabel )
        .background(
             ZStack{
                 if setting == tsVar.settingsHeader{
                     Color.backgroundPrimary
                     .frame(height: 1)
                     .offset(y: 14)
                     .matchedGeometryEffect(id: "CURRENTHEADER", in: animation)
                 }
             }
        )
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
    func getCategorieCell(_ item:SettingsOption) -> some View{
        return Section {
            switch item{
            case .DEGREES:
                SliderSection(sliderValue: $tubeViewModel.settingsVar.tube.grader,
                              minValue: 0,
                              maxValue: SLIDER_MAX_DEGREES,
                              textEnding: "°")
            case .DIMENSION:
                SliderSection(sliderValue: $tubeViewModel.settingsVar.tube.dimension,
                              minValue: 1,
                              maxValue:SLIDER_MAX_DIMENSION,
                              textEnding: "mm")
            case .SEGMENT:
                SliderSection(sliderValue: $tubeViewModel.settingsVar.tube.segment,
                              minValue: 0,
                              maxValue: SLIDER_MAX_SEGMENT,
                              textEnding: "st")
            case .STEEL:
                SliderSection(sliderValue: $tubeViewModel.settingsVar.tube.steel,
                              minValue: 1,
                              maxValue: SLIDER_MAX_DIMENSION,
                              textEnding: "mm")
            case .RADIUS:
                SliderSection(sliderValue: $tubeViewModel.settingsVar.tube.radie,
                              minValue: 1,
                              maxValue: SLIDER_MAX_RADIUS,
                              textEnding: "mm")
            case .LENA:
                SliderSection(sliderValue: $tubeViewModel.settingsVar.tube.lena,
                              minValue: 1,
                              maxValue: SLIDER_MAX_LENGTH,
                              textEnding: "mm")
            case .LENB:
                SliderSection(sliderValue: $tubeViewModel.settingsVar.tube.lenb,
                              minValue: 1,
                              maxValue: SLIDER_MAX_LENGTH,
                              textEnding: "mm")
            }
        } header: {
            Text(item.rawValue).foregroundColor(Color.systemGray)
        }
    }
    
    //MARK: - SWITCHES
    @ViewBuilder
    func getSwitchSection(header:String,imageName:String,index:Int) -> some View{
        VStack{
            HStack{
                listDotWithImage(imageName)
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
        Section {
            VStack{
                HStack{
                    Toggle(isOn:!self.$tubeViewModel.userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .KEEP_DEGREES)]){
                        Text("Adjust")
                    }.disabled(tubeViewModel.settingsVar.tube.segment < 2)
                    .toggleStyle(CheckboxStyle(alignLabelLeft: false,labelIsOnColor:.black))
                    Spacer()
                    Toggle(isOn: self.$tubeViewModel.userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .KEEP_DEGREES)]){
                        Text("Same")
                    }.disabled(tubeViewModel.settingsVar.tube.segment < 2)
                    .toggleStyle(CheckboxStyle(alignLabelLeft: true,labelIsOnColor:.black))
                    .onChange(of: self.tubeViewModel.userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .KEEP_DEGREES)]){ value in
                        tubeViewModel.rebuild()
                        tubeViewModel.settingsVar.redraw.toggle()
                    }
                }
                .hLeading()
                .padding([.leading,.trailing])
            }
        } header: {
            Text("Cut Angles").foregroundColor(Color.systemGray)
        }
        .opacity(tubeViewModel.settingsVar.tube.segment < 2 ? 0.2 : 1.0)
    }
    
    @ViewBuilder
    func getSwitchAutoAlign() -> some View{
        if tubeViewModel.userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .AUTO_ALIGN)]{
            Section {
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
           } header: {
               Text("Automatic Align").foregroundColor(Color.systemGray)
           }
        }
        else{
            Section {
                SliderSection(sliderValue: $tubeViewModel.settingsVar.tube.center,
                              minValue: -CGFloat.infinity,
                              maxValue: CGFloat.infinity,
                              textEnding: "",
                              isNotAlignmentSection: false)
            } header: {
                HStack{
                    Button(action: {
                        withAnimation{
                            self.tubeViewModel.userDefaultSettingsVar.drawOptions[DrawOption.indexOf(op: .AUTO_ALIGN)].toggle()
                            self.tubeViewModel.rebuild()
                        }
                    }){
                        Text("Automatic align").foregroundColor(Color.systemBlue)
                    }
                }
                .hCenter()
            }
        }
    }
    
    func getSwitchAddHundred() -> some View{
        Section {
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
        } header: {
            Text("Overlap").foregroundColor(Color.systemGray)
        }
        
    }
    @ViewBuilder
    func getSwitchSectionBase(index:Int) -> some View{
        switch index{
        case DrawOption.indexOf(op: .LABELSDEGREES):
            getSwitchSection(header: "Labels Degree",
                             imageName: "goforward.90",
                             index: DrawOption.indexOf(op: .LABELSDEGREES))
        case DrawOption.indexOf(op: .LABELSLENGTH):
            getSwitchSection(header: "Labels Length",
                             imageName: "textformat.123",
                             index: DrawOption.indexOf(op: .LABELSLENGTH))
        case DrawOption.indexOf(op: .CUTLINES):
            getSwitchSection(header: "Cutlines",
                             imageName: "line.diagonal",
                             index: DrawOption.indexOf(op: .CUTLINES))
        case DrawOption.indexOf(op: .CENTERLINE):
            getSwitchSection(header: "Center triangle",
                             imageName: "triangle",
                             index: DrawOption.indexOf(op: .CENTERLINE))
        case DrawOption.indexOf(op: .DIAGONALLINE):
            getSwitchSection(header: "Diagonal line",
                             imageName: "line.diagonal.arrow",
                             index: DrawOption.indexOf(op: .DIAGONALLINE))
        case DrawOption.indexOf(op: .MIDPOINT):
            getSwitchSection(header: "Midpoint",
                             imageName: "circle.and.line.horizontal",
                             index: DrawOption.indexOf(op: .MIDPOINT))
        case DrawOption.indexOf(op: .BOUNDINGBOX):
            getSwitchSection(header: "Boundingbox",
                             imageName: "rectangle",
                             index: DrawOption.indexOf(op: .BOUNDINGBOX))
        case DrawOption.indexOf(op: .TUBE_CENTERLINE):
            getSwitchSection(header: "Muff centerline",
                             imageName: "point.topleft.down.curvedto.point.bottomright.up.fill",
                             index: DrawOption.indexOf(op: .TUBE_CENTERLINE))
        case DrawOption.indexOf(op: .FULLCIRCLE):
            getSwitchSection(header: "Full circle",
                             imageName: "square.circle",
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
    
}
