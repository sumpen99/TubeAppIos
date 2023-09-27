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
