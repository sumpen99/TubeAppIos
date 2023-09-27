//
//  ScrollViewWithOffset2.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI

struct ScrollViewWithOffset2:View{
    @State var currentId: Int = 0
    @StateObject var viewModel = ScrollViewContentModel()
    
    // 1. pass proxy to the buttonView to be able to call proxy.scrollTo(id)
    private func buttonView(with proxy: ScrollViewProxy) -> some View {
        ZStack {
            Color.black
            HStack {
                // 2. pass proxy to the top button
                topButton(with: proxy)

                VStack {
                    Button("Next page") {
                          // 3. when 'Next page' button is tapped
                         // scroll should move to the child's id
                        if currentId < viewModel.contentItems.count - 1 {
                            proxy.scrollTo(currentId + 1)
                            currentId = currentId + 1
                        }
                    }
                    .padding(5)
                    
                    Text("Current page: \(currentId)")
                        .foregroundColor(.white)
                }

                // 4. pass proxy to the bottom button
                bottomButton(with: proxy)
            }
        }
        .frame(height: 50.0)
    }
    
    private func topButton(with proxy: ScrollViewProxy) -> some View {
        Button(action: {
            // when tapped, scroll to the first child view
            proxy.scrollTo(0)
            currentId = 0
        }, label: {
            Image(systemName: "arrow.up")
                .foregroundColor(.white)
        })
        .padding(.horizontal)
    }
    
    private func bottomButton(with proxy: ScrollViewProxy) -> some View {
        Button(action: {
            // when tapped, scroll to the last child view
            let lastItemId = viewModel.contentItems.count - 1
            proxy.scrollTo(lastItemId)
            currentId = lastItemId
        }, label: {
            Image(systemName: "arrow.down")
                .foregroundColor(.white)
        })
        .padding(.horizontal)
    }

   var body:some View{
        VStack(spacing: 10.0) {
            ScrollViewReader { proxy in
                buttonView(with: proxy)
                ScrollView(.vertical) {
                    LazyVStack {
                        ForEach(viewModel.contentItems) { item in
                            Text("\(item.id)").foregroundColor(Color.white).font(.largeTitle).padding()
                            .id(item.id)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom)
   }
    
}

final class ScrollViewContentModel: ObservableObject {
    
    var contentItems: [ContentItem] = ContentItem.defaultContent()
}

struct ContentItem: Identifiable {
    var id: Int
    
    var colour: Color
    
    init(id: Int, colour: Color?) {
        self.id = id
        self.colour = colour ?? .gray
    }
    
    static func defaultContent() -> [ContentItem] {
        let colours: [Color] = Array(repeating: Color.random, count: 50).compactMap { $0 }
        
        return colours.enumerated().map { iterator, colour in
            ContentItem(id: iterator, colour: colour)
        }
    }
}
