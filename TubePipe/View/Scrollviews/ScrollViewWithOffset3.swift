//
//  ScrollViewWithOffset3.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI

enum ScrollOffsetNamespace {

    static let namespace = "scrollView"
}

struct ScrollOffsetPreferenceKey: PreferenceKey {

    static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

struct ScrollViewOffsetTracker: View {

    var body: some View {
        GeometryReader { geo in
            Color.clear
                .preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: geo.frame(in: .named(ScrollOffsetNamespace.namespace)).origin
                )
        }
        .frame(height: 0)
    }
}

private extension ScrollView {

    func withOffsetTracking(action: @escaping (_ offset: CGPoint) -> Void) -> some View {
        self.coordinateSpace(name: ScrollOffsetNamespace.namespace)
            .onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: action)
    }
}

public struct ScrollViewWithOffset<Content: View>: View {

    public init(
        _ axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        onScroll: ScrollAction? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.onScroll = onScroll ?? { _ in }
        self.content = content
    }

    private let axes: Axis.Set
    private let showsIndicators: Bool
    private let onScroll: ScrollAction
    private let content: () -> Content

    public typealias ScrollAction = (_ offset: CGPoint) -> Void

    public var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            ZStack(alignment: .top) {
                ScrollViewOffsetTracker()
                content()
            }
        }
        .withOffsetTracking(action: onScroll)
    }
}

struct InfiniteListView: View {
    @EnvironmentObject var infiniteListViewModel:InfiniteListViewModel
    @State var currentScrollOffset:CGPoint?
    // 1
    //init() {
         // infiniteListViewModel.requestInitialSetOfItems()
    //}
    
    func handleScroll(_ offset: CGPoint) {
        currentScrollOffset = offset
    }
    
    var body: some View{
        if let items = infiniteListViewModel.items?.enumerated().map({ $0 }) {
            GeometryReader{ reader in
                ScrollViewReader { proxy in
                    ScrollViewWithOffset(onScroll: handleScroll) {
                        LazyVStack(spacing:10) {
                            ForEach(items,id:\.element.id) { index, item in
                                ListItemRowView(item: item,index: index)
                                    .id(item.id)
                                    .onAppear { infiniteListViewModel.requestMoreItemsIfNeeded(index: index)
                                    }
                            }
                        }
                    }
                    .overlay {
                        if infiniteListViewModel.dataIsLoading {
                            //LoadingView()
                        }
                    }
                    .onAppear{
                        infiniteListViewModel.scrollViewHeight = reader.size.height
                        if let itemIdOnTop = infiniteListViewModel.itemIdOnTop{
                            proxy.scrollTo(itemIdOnTop)
                        }
                    }
                    .onDisappear{
                        infiniteListViewModel.lastScrollOffset = currentScrollOffset
                    }
                
                }
            }
            
            
        }
    }
}
