//
//  ToastView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-10-22.
//

import SwiftUI

struct ToastView: View {
  var style: ToastStyle
  var message: String
  
  var body: some View {
    HStack(alignment: .center, spacing: 12) {
      Image(systemName: style.iconFileName)
      .font(.title)
      .foregroundColor(style.themeColor)
      Text(message)
      .font(.headline)
      .italic()
      .foregroundColor(Color.darkGray)
    }
    .padding()
    .background(Color.GHOSTWHITE)
    .cornerRadius(24)
    .padding(.horizontal, 48)
    .hCenter()
    .vCenter()
  }
}
