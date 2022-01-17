//
//  ContentHeader.swift
//  craptv
//
//  Created by Alex on 05/11/2021.
//

import Foundation
import SwiftUI

struct ContentHeaderView: View {

  @ObservedObject var api = API.Adapter

  var title: String
  var icon: ContentToggleIcon
  var apiType: API.FetchType?

  var body: some View {
    HStack(alignment: .center, spacing: 0) {
      ControlSFSymbolView(icon: icon, width: Theme.Font.Size.big)
        .padding()
        .contentShape(Rectangle())
        .onTapGesture(perform: {
          NotificationCenter.default.post(
            name: .contentToggle,
            object: Player.instance.contentToggle
          )
        })
      Spacer()
      Text(title)
        .font(Theme.Font.title)
        .lineLimit(1)
        .textCase(.uppercase)
        .opacity(1)
        .padding()
    }.background(Theme.Color.Background.header)
  }
}
