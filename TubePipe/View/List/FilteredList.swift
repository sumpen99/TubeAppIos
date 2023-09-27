//
//  FilteredList.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-24.
//

import SwiftUI
import CoreData

// replace TubeModel -> T
struct FilteredList<T: NSManagedObject, Content: View>: View {
    @FetchRequest var fetchRequest: FetchedResults<TubeModel>
    let layout = [
            GridItem(.flexible(minimum: 40)),
            GridItem(.flexible(minimum: 40)),
            GridItem(.flexible(minimum: 40)),
    ]
    // this is our content closure; we'll call this once for each item in the list
    let content: (TubeModel) -> Content
    
    var body: some View {
        LazyVGrid(columns:layout,spacing: V_GRID_SPACING,pinnedViews: [.sectionHeaders]){
            ForEach(fetchRequest, id: \.self){ tube in
                self.content(tube)
            }
        }
    }
    
    func removeTubes(at offsets: IndexSet) {
        for index in offsets {
            let tube = fetchRequest[index]
            PersistenceController.shared.container.viewContext.delete(tube)
        }
    }

    init(filterKey: String, filterValue: String, @ViewBuilder content: @escaping (TubeModel) -> Content) {
        _fetchRequest = FetchRequest<TubeModel>(sortDescriptors: [],
                                        predicate: NSPredicate(format: "%K BEGINSWITH %@", filterKey, filterValue))
         self.content = content
    }
    
    /*init(filterStartDate:NSDate,filterEndDate:NSDate,@ViewBuilder content: @escaping (TubeModel) -> Content) {
        _fetchRequest = FetchRequest<TubeModel>(sortDescriptors: [SortDescriptor(\TubeModel.date)],
                                        predicate: NSPredicate(format: "date >= %@ AND date < %@",
                                                               filterStartDate,
                                                               filterEndDate))
        self.content = content
    }*/
    init(filterStartDate:NSDate,filterEndDate:NSDate,@ViewBuilder content: @escaping (TubeModel) -> Content) {
            let request: NSFetchRequest<TubeModel> = TubeModel.fetchRequest()
            let predicate = NSPredicate(format: "date >= %@ AND date < %@",
                                        filterStartDate,
                                        filterEndDate)
            let sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            request.predicate = predicate
            request.sortDescriptors = sortDescriptors
            request.includesSubentities = false
            _fetchRequest = FetchRequest(fetchRequest: request)
            self.content = content
        }
    
    init(fetchOffset:Int,fetchLimit:Int,@ViewBuilder content: @escaping (TubeModel) -> Content) {
        let request: NSFetchRequest<TubeModel> = TubeModel.fetchRequest()
        /*let predicate = NSPredicate(format: "date >= %@ AND date < %@",
                                    filterStartDate,
                                    filterEndDate)*/
        let sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchOffset = fetchOffset
        request.fetchLimit = fetchLimit
        //request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        request.includesSubentities = false
        _fetchRequest = FetchRequest(fetchRequest: request)
        self.content = content
    }
    
}

