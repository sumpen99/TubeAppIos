//
//  CoreDataViewModel.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI
import CoreData

class CoreDataService{
    let CORE_DATA_FETCH_LIMIT = 200
    
    var totalItems:Int = 0
    var totalPages:Int = 0
    var currentPage:Int = 0
    
    func incremeantPageIndex(){ currentPage += 1 }
    var nextOffset:Int{ currentPage * CORE_DATA_FETCH_LIMIT }
    var hasDataToFetch:Bool{ currentPage < totalPages && totalItems > 0 }
    
    func resetValues(){
        totalItems = 0
        totalPages = 0
        currentPage = 0
        rebuildPageIndex()
    }
    
    func rebuildPageIndex(){
        totalItems = PersistenceController.fetchCountWithoutPredicate()
        totalPages = totalItems/CORE_DATA_FETCH_LIMIT + 1
    }
    
    func requestItems(page:Int,onResult: @escaping ((totalItems:Int,items:[TubeModel])) -> Void) {
        if hasDataToFetch{
            let nextOffset = nextOffset
            let fetchLimit = CORE_DATA_FETCH_LIMIT
            incremeantPageIndex()
            DispatchQueue.global().async{
                let items = self.fetchedRequest(fetchOffset: nextOffset, fetchLimit: fetchLimit)
                onResult((totalItems:self.totalItems,items:items))
            }
        }
        onResult((totalItems:totalItems,items:[]))
    }
    
    func fetchedRequest(fetchOffset:Int,fetchLimit:Int) -> [TubeModel]{
        let fetchRequest: NSFetchRequest<TubeModel> = TubeModel.fetchRequest()
        let sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.fetchOffset = fetchOffset
        fetchRequest.fetchLimit = fetchLimit
        //fetchRequest.fetchBatchSize = fetchLimit
        //fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.includesSubentities = false
        do {
            return try PersistenceController.shared.container.viewContext.fetch(fetchRequest)
        } catch {
            debugLog(object: "Failed to fetch tubemodels: \(error)")
            return []
        }
     }
    
    func requestItemsBySearchCategorie(_ categorie:SearchCategorie,
                                       searchText:String,
                                       onResult: @escaping ((totalItems:Int,items:[TubeModel])) -> Void) {
        DispatchQueue.global().async{
            let items = self.fetchedRequestBySearchCategorie(categorie,searchText:searchText)
            onResult((totalItems:items.count,items:items))
        }
    }
    
    func fetchedRequestBySearchCategorie(_ categorie:SearchCategorie,searchText:String) -> [TubeModel]{
        guard let predicate = getPredicateBySearchCategorie(categorie,searchText: searchText)
        else{ return [] }
        let fetchRequest: NSFetchRequest<TubeModel> = TubeModel.fetchRequest()
        let sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.includesSubentities = false
        do {
            return try PersistenceController.shared.container.viewContext.fetch(fetchRequest)
        } catch {
            debugLog(object: "Failed to fetch tubemodels: \(error)")
            return []
        }
     }
    
    func getPredicateBySearchCategorie(_ categorie:SearchCategorie,searchText:String) -> NSPredicate?{
        //predicate = NSPredicate(format: "%K =[c] %@", argumentArray: [#keyPath(TubeModel.message), searchValue])//caseinsensitive
        switch categorie{
            case .MESSAGE:
            return NSPredicate(format: "message contains[c] %@", searchText)
            case .SEGMENT:
            return NSPredicate(format: "segment == %@",searchText)
            case .DEGREES:
            return NSPredicate(format: "grader == %@",searchText)
            case .DIMENSION:
            return NSPredicate(format: "dimension == %@",searchText)
            case .STEEL:
            return NSPredicate(format: "steel == %@",searchText)
            case .LENA:
            return NSPredicate(format: "lena == %@",searchText)
            case .LENB:
            return NSPredicate(format: "lenb == %@",searchText)
            case .RADIUS:
            return NSPredicate(format: "radie == %@",searchText)
            default:return nil
        }
    }
}

class CoreDataViewModel:ObservableObject{
    
    private let itemsFromEndThreshold = 10
    
    private var totalItemsAvailable: Int?
    private var itemsLoadedCount: Int?
    private var page = 0
    
    private let coreDataFetcher: CoreDataService = CoreDataService()
    
    var currentScrollOffset: CGPoint?
    var scrollViewHeight:CGFloat?
    var lastScrollOffset: CGPoint?
    var childViewHeight:CGFloat?
    var spacing:CGFloat?
    @Published var items: [TubeModel]? = []
    @Published var dataIsLoading = false
    
    func requestInitialSetOfItems(){
        /*guard let itemsLoadedCount = itemsLoadedCount
        else{
            rebuild()
            return
        }
        if itemsLoadedCount <= 0 {
            rebuild()
        }*/
        resetValues()
        requestItems(page: page)
    }
    
    func requestMoreItemsIfNeeded(index: Int) {
        guard let itemsLoadedCount = itemsLoadedCount,
              let totalItemsAvailable = totalItemsAvailable else {
            return
        }
        if thresholdMeet(itemsLoadedCount, index) && moreItemsRemaining(itemsLoadedCount, totalItemsAvailable) {
            page += 1
            requestItems(page: page)
        }
    }
    
    private func requestItems(page: Int) {
        dataIsLoading = true
        Task {
            self.coreDataFetcher.requestItems(page: page){ response in
                DispatchQueue.main.async{
                    self.totalItemsAvailable = response.totalItems
                    self.items?.append(contentsOf: response.items)
                    self.itemsLoadedCount = self.items?.count
                    self.dataIsLoading = false
                }
            }

        }
    }
    
    func requestBySearchCategorie(_ categorie:SearchCategorie,searchText:String){
        dataIsLoading = true
        Task {
            self.coreDataFetcher.requestItemsBySearchCategorie(categorie,searchText: searchText){ response in
                DispatchQueue.main.async{
                    self.resetValues()
                    self.totalItemsAvailable = response.totalItems
                    self.items?.append(contentsOf: response.items)
                    self.itemsLoadedCount = self.items?.count
                    self.dataIsLoading = false
                }
            }

        }
    }
    
    func getTubeById(_ tubeId:String) -> TubeModel?{
        if let index = items?.firstIndex(where: {$0.id == tubeId}){
            return items?[index]
        }
        return nil
    }
    
}

extension CoreDataViewModel{
    
    var hasItemsLoaded:Bool{
        if let count = items?.count{ return count > 0 }
        return false
    }
    
    var itemIdOnTop: String?{
        if let itemCount = items?.count,
            let spacing = spacing,
            let childViewHeight = childViewHeight,
            let lastScrollOffset = lastScrollOffset,
            let scrollViewHeight = scrollViewHeight{
            let scroll = (lastScrollOffset.y * -1)
            
            let childrenPossiblOnScreen = Int(round(scrollViewHeight/(childViewHeight+spacing)))
            
            let childAtBottomIndex = Int(round(scroll/(childViewHeight+spacing))) + childrenPossiblOnScreen
            
            let newIndex = childAtBottomIndex - childrenPossiblOnScreen
            
            
            if 0 <= newIndex && newIndex < itemCount{
                return items?[newIndex].id
            }
        }
        return nil
    }
    
    private func thresholdMeet(_ itemsLoadedCount: Int, _ index: Int) -> Bool {
        return (itemsLoadedCount - index) == itemsFromEndThreshold
    }
    
    private func moreItemsRemaining(_ itemsLoadedCount: Int, _ totalItemsAvailable: Int) -> Bool {
        return itemsLoadedCount < totalItemsAvailable
    }
    
    func setScrollViewDimensions(_ spacing:CGFloat,scrollViewHeight:CGFloat){
        self.spacing = spacing
        self.scrollViewHeight = scrollViewHeight
    }
    
    func setChildViewDimension(_ childViewHeight:CGFloat){
        self.childViewHeight = childViewHeight
    }
    
    func resetValues(){
        page = 0
        items?.removeAll()
        coreDataFetcher.resetValues()
    }
    
    
}