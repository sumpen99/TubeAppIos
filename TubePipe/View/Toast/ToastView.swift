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
      .foregroundStyle(style.themeColor)
      Text(message)
      .font(.callout)
      .italic()
      .foregroundStyle(Color.black)
    }
    .padding()
    .background(
        RoundedRectangle(cornerRadius: 8).stroke(Color.black).background{ Color.white }
    )
    .padding(.horizontal)
    .hCenter()
    .vCenter()
  }
}
