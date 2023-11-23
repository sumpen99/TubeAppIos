//
//  InboxView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-19.
//

import SwiftUI

enum SearchCategorie : String{
    case MESSAGE = "Message"
    case SEGMENT = "Segment"
    case DEGREES = "Degrees"
    case DIMENSION = "Dimension"
    case STEEL = "Steel"
    case LENA = "Len A"
    case LENB = "Len B"
    case RADIUS = "Radius"
    case ALL = "ALL"
}

extension SearchCategorie{
    static func indexOf(op:SearchCategorie) -> Int{
        switch op{
        case .MESSAGE:      return 1
        case .SEGMENT:      return 2
        case .DEGREES:      return 3
        case .DIMENSION:    return 4
        case .STEEL:        return 5
        case .LENA:         return 6
        case .LENB:         return 7
        case .RADIUS:       return 8
        case .ALL:          return 9
        }
    }
}

struct InboxVar{
    var currentTube:TubeModel?
    var userWillEditTubes:Bool = false
    var userWillFilterTubes:Bool = false
    var isDeleteTube:Bool = false
    var collapseCategories:Bool = true
    var searchCategorie:SearchCategorie?
    var deleteTubesId:[String] = []
    var tubeModel:TubeModel?
    var searchResult:Int = 0
    var searchText:String = ""
    var searchOption:[Bool] = Array.init(repeating: false,
                                         count: SearchCategorie.indexOf(op: .ALL))
    var lastSetIndex:Int = 0
    
    mutating func clearSearch(){
        searchText = ""
    }
    
    func listContainsId(_ id:String?) -> Bool{
        if let id = id{
            return deleteTubesId.contains(where: { $0 == id })
        }
        return false
    }
    
    mutating func toggleListWithId(_ id:String?){
        if let id = id{
            if listContainsId(id){
                deleteTubesId.removeAll(where: { $0 == id })
            }
            else{
                deleteTubesId.append(id)
            }
        }
    }
    
    mutating func clearListOfIds(){
        deleteTubesId.removeAll()
    }
    
    mutating func setNewSearchIndex(_ index:Int){
        if lastSetIndex != index{
            searchOption[lastSetIndex] = false
        }
        lastSetIndex = index
    }
    
    mutating func clearSearchOptions(){
        searchOption = Array.init(repeating: false,count: SearchCategorie.indexOf(op: .ALL))
    }
    
}

struct InboxSavedTubesView:View{
    @Namespace var animation
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @EnvironmentObject var tubeViewModel: TubeViewModel
    @StateObject var coreDataViewModel:CoreDataViewModel
    @State var iVar:InboxVar = InboxVar()
    let childViewHeight:CGFloat = 50.0
    
    init() {
        self._coreDataViewModel = StateObject(wrappedValue: CoreDataViewModel())
    }
    
    @ViewBuilder
    var topMenuList:  some View{
        if !iVar.userWillEditTubes{
            FilterSearchMenu(iVar: $iVar,onSearch: onSearch,onReset: onReset)
            .matchedGeometryEffect(id: "CURRENT_SEARCH_CATEGORIE", in: animation)
        }
        else{
            deleteSelectedField
        }
    }
    
    var deleteSelectedField:some View{
        VStack(spacing:V_SPACING_REG){
            labelSelected
            removeButton
        }
        .opacity(iVar.deleteTubesId.count <= 0 ? 0.5 : 1.0)
        .disabled(iVar.deleteTubesId.count <= 0)
        .padding([.leading,.trailing,.top])
    }
    
    var savedTubesList:some View{
        ScrollViewCoreData(coreDataViewModel:coreDataViewModel){ tube in
            ExtendedTubeDocFileView(userWillEditTubes: $iVar.userWillEditTubes,
                               tube: tube,
                               onSelected: onSelected,
                               onToggleListWithId: onToggleListWithId,
                               onListContainsId: onListContainsId,
                               childViewHeight: childViewHeight)
        }
        .background{
            Color.lightText.edgesIgnoringSafeArea(.all)
        }
    }
    
    var noItemsToShowPage:some View{
        labelItems.vTop()
    }
    
    var itemsLoadedPage:some View{
        VStack(spacing:V_SPACING_REG){
            labelItems
            topMenuList
            savedTubesList
        }
        .padding([.leading,.trailing,.top])
    }
    
    var mainpage:some View{
        itemsLoadedPage
        .onAppear{
            coreDataViewModel.setChildViewDimension(childViewHeight)
            coreDataViewModel.requestInitialSetOfItems()
        }
        .onDisappear{
            coreDataViewModel.resetPageCounter()
        }
    }
    
    var body: some View{
        AppBackgroundStack(content: {
            mainpage
        },title: "Storage")
        .alert(isPresented: $iVar.isDeleteTube, content: {
            onAlertWithOkAction(actionPrimary: {
                deleteSelectedItems()
                withAnimation{
                    iVar.userWillEditTubes.toggle()
                }
           })
        })
        .onChange(of: iVar.tubeModel){ tube in
            if let tube = tube{
                iVar.tubeModel = nil
                SheetPresentView(style: .sheet){
                    SelectedTubeView(tubeModel: tube,
                                     labelBackButton: "List",
                                     loadViewModelWithTubeModel: loadViewModelWithTubeModel,
                                     deleteTubeModel: deleteTubeModel)
                }
                .makeUIView()
            }
            
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                leadingButton
             }
            ToolbarItem(placement: .navigationBarTrailing) {
                toggleEditButton
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
}

extension InboxSavedTubesView{
    //MARK: -- LABELS
    var labelSelected:some View{
        Text("\(iVar.deleteTubesId.count) selected")
        .largeTitle()
    }
    
    @ViewBuilder
    var labelItems:some View{
       if let categorie = iVar.searchCategorie{
           let txt = iVar.searchResult == 0 ? "\(categorie.rawValue)" :
                                              "\(categorie.rawValue):\(iVar.searchResult)"
            VStack{
                Text("All files")
                .largeTitle(color: .black)
                Text(txt)
                .font(.body)
                .bold()
                .foregroundColor(.black)
                .hLeading()
            }
       }
        else{
            Text("All files")
            .largeTitle(color: .black)
        }
        
        
    }
    
    //MARK: -- BUTTONS
    var selectAllButton:some View{
        Button("Select all", action: selectAllItems )
        .buttonStyle(ButtonStyleList(color: Color.editorieButton))
    }
    
    var removeButton:some View{
        Button("Remove", action: removeTubeAlert )
        .buttonStyle(ButtonStyleList(color: Color.systemRed)).hLeading()
    }
    
    var cancelButton:some View{
        Button("Cancel", action: {
            iVar.clearListOfIds()
            withAnimation{
                iVar.userWillEditTubes.toggle()
            }
        })
        .buttonStyle(ButtonStyleList(color: Color.systemRed))
    }
    
    var editButton:some View{
        Button("Edit", action: {
            withAnimation{
                iVar.userWillEditTubes.toggle()
            }
        })
        .buttonStyle(ButtonStyleList(color: Color.editorieButton))
    }
    
    @ViewBuilder
    var leadingButton:some View{
        if iVar.userWillEditTubes{
            selectAllButton
        }
        else{
            BackButton(title: "Calendar")
            .toolbarFontAndPadding()
        }
   }
    
    @ViewBuilder
    var toggleEditButton:some View{
        if coreDataViewModel.hasItemsLoaded{
            if iVar.userWillEditTubes{
                cancelButton
            }
            else{
                editButton
            }
        }
    }
    
    //MARK: - IVAR FUNCTIONS
    func onSelected(_ tube:TubeModel){ iVar.tubeModel = tube }
    func onToggleListWithId(_ tubeId:String?){ iVar.toggleListWithId(tubeId) }
    func onListContainsId(_ tubeId:String?) -> Bool{ return iVar.listContainsId(tubeId) }
    
    //MARK: - SEARCH FUNCTIONS
    func onSearch(_ searchCategorie:SearchCategorie,searchText:String){
        iVar.searchResult = 0
        coreDataViewModel.requestBySearchCategorie(searchCategorie, searchText: searchText){ itemsCount in
            iVar.searchResult = itemsCount
        }
    }
    func onReset(){
        coreDataViewModel.requestInitialSetOfItems()
    }
    
    //MARK: - HELPERFUNCTIONS
    func removeTubeAlert(){
        ALERT_TITLE = "Remove tubes"
        ALERT_MESSAGE = "Do you want to remove all selected tubes?"
        iVar.isDeleteTube.toggle()
    }
    
    func selectAllItems(){
        if let items = coreDataViewModel.items?.compactMap({$0.id ?? ""}){
            iVar.deleteTubesId.removeAll()
            iVar.deleteTubesId.append(contentsOf: items)
        }
    }
    
    func deleteSelectedItems(){
        DispatchQueue.global().async {
            for tubeId in iVar.deleteTubesId{
                if let tube = coreDataViewModel.getTubeById(tubeId){
                    PersistenceController.deleteTubeImage(tube.image)
                    PersistenceController.deleteTubeModel(tube)
                }
            }
            resetListOfSavedTubes()
        }
     }
    
    func deleteTubeModel(_ tube:TubeModel){
        PersistenceController.deleteTubeImage(tube.image)
        PersistenceController.deleteTubeModel(tube)
        resetListOfSavedTubes()
    }
    
    func resetListOfSavedTubes(){
        DispatchQueue.main.async{
            iVar.clearListOfIds()
            coreDataViewModel.requestInitialSetOfItems()
        }
    }
    
    func loadViewModelWithTubeModel(_ tubeModel:TubeModel){
        tubeViewModel.initViewFromModelValues(tubeModel)
        tubeViewModel.rebuild()
        navigationViewModel.navTo(.MODEL_2D)
    }
    
}
