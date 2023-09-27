//
//  DeviceShakeModifier.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//
import SwiftUI

struct DeviceShakeViewModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                action()
            }
    }
}

