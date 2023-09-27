//
//  ScrollviewWithOffset1.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI
import Combine
struct _ScrollViewWithOffset<Content: View>: View {
    
    private let axis: Axis.Set
    private let content: (CGPoint) -> Content
    private let didEndScrolling: (CGPoint) -> Void
    private let offsetObserver = PassthroughSubject<CGPoint, Never>()
    private let spaceName = "scrollView"
    
    init(axis: Axis.Set = .vertical,
         content: @escaping (CGPoint) -> Content,
         didEndScrolling: @escaping (CGPoint) -> Void = { _ in }) {
        self.axis = axis
        self.content = content
        self.didEndScrolling = didEndScrolling
    }
    
    var body: some View {
        ScrollView(axis) {
            GeometryReader { geometry in
                content(geometry.frame(in: .named(spaceName)).origin)
                    .onChange(of: geometry.frame(in: .named(spaceName)).origin, perform: offsetObserver.send)
                    .onReceive(offsetObserver.debounce(for: 0.2, scheduler: DispatchQueue.main), perform: didEndScrolling)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .coordinateSpace(name: spaceName)
    }
}
struct ScrollViewWithOffset1<Content: View>: View {
    @State private var height: CGFloat?
    @State private var width: CGFloat?
    let axis: Axis.Set
    let content: (CGPoint) -> Content
    let didEndScrolling: (CGPoint) -> Void
    
    var body: some View {
        _ScrollViewWithOffset(axis: axis) { offset in
            content(offset)
                .fixedSize()
                .overlay(GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            height = geo.size.height
                            width = geo.size.width
                        }
                })
        } didEndScrolling: {
            didEndScrolling($0)
        }
        .frame(width: axis == .vertical ? width : nil,
              height: axis == .horizontal ? height : nil)
    }
}

struct InfiniteListView1: View {
    @EnvironmentObject var infiniteListViewModel:InfiniteListViewModel
    @State var currentScrollOffset:CGPoint?
    @State var cpt = 0
    // 1
    //init() {
        // infiniteListViewModel.requestInitialSetOfItems()
    //}
    
    func handleScroll(_ offset: CGPoint) {
        currentScrollOffset = offset
    }
    
    
    
    var body:some View{
        if let items = infiniteListViewModel.items?.enumerated().map({ $0 }) {
            ScrollViewReader { proxy in
                ScrollViewWithOffset1(axis: .vertical) { offset in
                    LazyVStack {
                        ForEach(items,id:\.element.id) { index, item in
                            ListItemRowView(item: item,index: index)
                                .id(item.id)
                                .onAppear { infiniteListViewModel.requestMoreItemsIfNeeded(index: index)
                               }
                        }
                    }
                }
                
                didEndScrolling: { _ in
                    cpt += 1
                }
                .overlay {
                    if infiniteListViewModel.dataIsLoading {
                        //LoadingView()
                    }
                }
                .onAppear{
                    /*if let itemIdOnTop = infiniteListViewModel.itemIdOnTop{
                        proxy.scrollTo(itemIdOnTop)
                    }*/
                }
            }
             
         }
    }
    
    
    
    
}
