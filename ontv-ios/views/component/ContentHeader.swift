//
//  ContentHeader.swift
//  craptv
//
//  Created by Alex on 05/11/2021.
//

import Foundation
import SwiftUI

struct ContentHeaderView: View {

  var title: String
  var icon: ContentToggleIcon
  
  var body: some View {
    HStack(alignment: .center, spacing: 0) {
      ControlSFSymbolView(icon: icon, width: Theme.Font.Size.larger)
        .padding()
        .onTapGesture(perform: {
          NotificationCenter.default.post(
            name: .contentToggle,
            object: Player.instance.contentToggle
          )
        })
      Spacer().background(.yellow)
      Text(title)
        .font(Theme.Font.title)
        .lineLimit(1)
        .textCase(.uppercase)
        .opacity(1)
        .padding()
    }.background(Theme.Color.Background.header)
  }
}
