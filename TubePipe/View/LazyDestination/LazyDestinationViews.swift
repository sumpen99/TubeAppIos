//
//  LazyDestinationViews.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-20.
//

import SwiftUI

struct LazyDestination<Destination: View>: View {
    var destination: () -> Destination
    var body: some View {
        self.destination()
    }
}

struct PersistentContentView<Content: View>: View, Equatable {
    static func == (lhs: PersistentContentView<Content>, rhs: PersistentContentView<Content>) -> Bool {
        true
    }

    let content: () -> Content

    var body: some View {
        content()
    }
}
