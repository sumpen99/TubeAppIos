//
//  InfiniteCoreDataScrollView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI

struct ScrollViewCoreData<Content: View>: View {
    @EnvironmentObject var coreDataViewModel:CoreDataViewModel
    @State var currentScrollOffset:CGPoint?
    let layout = [
            GridItem(.flexible(minimum: 40)),
            GridItem(.flexible(minimum: 40)),
            GridItem(.flexible(minimum: 40)),
    ]
    var content: (TubeModel) -> Content
   
    func handleScroll(_ offset: CGPoint) {
        currentScrollOffset = offset
    }
    
    var body: some View{
        if let items = coreDataViewModel.items?.enumerated().map({ $0 }) {
            GeometryReader{ reader in
                ScrollViewReader { proxy in
                    ScrollViewWithOffset(onScroll: handleScroll) {
                        LazyVGrid(columns:layout,spacing: V_GRID_SPACING,pinnedViews: [.sectionHeaders]){
                            ForEach(items,id:\.element.id){ index, tube in
                                content(tube)
                                    .id(tube.id)
                                    .onAppear {
                                        coreDataViewModel.requestMoreItemsIfNeeded(index: index)
                                    }
                            }
                            .onAppear{
                                coreDataViewModel.setScrollViewDimensions(V_SPACING_REG,scrollViewHeight: reader.size.height)
                            }
                        }
                        .padding(.top)
                     }
                    .overlay {
                        if coreDataViewModel.dataIsLoading {
                            //LoadingView()
                        }
                    }
                    .onAppear{
                        if let itemIdOnTop = coreDataViewModel.itemIdOnTop{
                            proxy.scrollTo(itemIdOnTop)
                        }
                    }
                    .onDisappear{
                        coreDataViewModel.lastScrollOffset = currentScrollOffset
                    }
                
                }
            }
        }
    }
}
