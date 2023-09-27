//
//  TimeEventViews.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI

struct TimeEventGeneratorView: View {
    var callback: () -> Void
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        Color.clear
        .onReceive(self.timer) { _ in
            self.callback()
        }
    }
}
