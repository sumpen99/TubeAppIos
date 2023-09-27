//
//  InfiniteListViewModel.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-20.
//

import SwiftUI
let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"


struct ListItemRowView:View{
    let item:ListItem
    let index:Int
    var body:some View{
         Text("Index: \(index) Label: \(item.label)")
            .frame(height:MENU_HEIGHT)
            //.padding()
            .background{
                RoundedRectangle(cornerRadius: 10.0).fill(item.color)
            }
           
   }
}

struct ListItem:Identifiable,Hashable{
    let id:String? = UUID().uuidString
    let color:Color = Color.random
    let label:String = String((0..<5).map{ _ in letters.randomElement() ?? "?" })
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
        
    static func == (lhs: ListItem, rhs: ListItem) -> Bool {
        return lhs.id == rhs.id
    }
    
}

class NetworkService{
    let totalPages = 10
    let badge = 10
    var currentPage = 0
    
    var totalItems:Int{ totalPages * badge }
    
    func requestItems(page:Int,onResult: @escaping ((totalItems:Int,items:[ListItem])) -> Void) {
        if currentPage < totalPages{
            currentPage += 1
            var items:[ListItem] = []
            let totalItems = totalItems
            DispatchQueue.global().async{
                for _ in 0..<self.badge{
                    items.append(ListItem())
                }
                onResult((totalItems:totalItems,items:items))
            }
        }
        onResult((totalItems:totalItems,items:[]))
    }
}

class InfiniteListViewModel: ObservableObject {
    private let itemsFromEndThreshold = 5
    
    private var totalItemsAvailable: Int?
    private var itemsLoadedCount: Int?
    private var page = 0
    
    private let networkService: NetworkService = NetworkService()
    
    var scrollViewHeight:CGFloat?
    var currentScrollOffset: CGPoint?
    var lastScrollOffset: CGPoint?
    @Published var items: [ListItem]? = []
    @Published var dataIsLoading = false
    let childViewHeight:CGFloat = 50.0
    let padding:CGFloat = 10.0
    
    var itemIdOnTop: String?{
        if let itemCount = items?.count,
            let lastScrollOffset = lastScrollOffset,
            let scrollViewHeight = scrollViewHeight{
            let scroll = (lastScrollOffset.y * -1)
            
            let childrenPossiblOnScreen = Int(round(scrollViewHeight/(childViewHeight+padding)))
            
            let childAtBottomIndex = Int(round(scroll/(childViewHeight+padding))) + childrenPossiblOnScreen
            
            let newIndex = childAtBottomIndex - childrenPossiblOnScreen
            
            
            if 0 <= newIndex && newIndex < itemCount{
                return items?[newIndex].id
            }
        }
        return nil
    }
    
    func requestInitialSetOfItems() {
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
            self.networkService.requestItems(page: page){ response in
                DispatchQueue.main.async{
                    self.totalItemsAvailable = response.totalItems
                    self.items?.append(contentsOf: response.items)
                    self.itemsLoadedCount = self.items?.count
                    self.dataIsLoading = false
                }
            }
            
        }
    }
    
    private func thresholdMeet(_ itemsLoadedCount: Int, _ index: Int) -> Bool {
        return (itemsLoadedCount - index) == itemsFromEndThreshold
    }
    
    private func moreItemsRemaining(_ itemsLoadedCount: Int, _ totalItemsAvailable: Int) -> Bool {
        return itemsLoadedCount < totalItemsAvailable
    }
}


/*
 private func requestItems(page: Int) {
         dataIsLoading = true
         Task {
             let response = await networkService.requestItems(page: page)
             totalItemsAvailable = response.totalItems
             await MainActor.run {
                 items?.append(contentsOf: response.items)
                 itemsLoadedCount = items?.count
                 dataIsLoading = false
             }
         }
     }
 
 */
