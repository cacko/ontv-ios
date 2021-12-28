//
//  ControlSFSymbol.swift
//  ontv
//
//  Created by Alex on 18/11/2021.
//

import Foundation
import SwiftUI

struct ControlSFSymbolView: View {

  var icon: ContentToggleIcon
  var width: Double!

  @ObservedObject var player = Player.instance

  var body: some View {
    Image(systemName: icon.rawValue)
      .foregroundStyle(.white, .gray)
      .symbolVariant(.circle.fill)
      .imageScale(.medium)
      .symbolRenderingMode(.hierarchical)
      .font(.system(size: width ?? player.iconSize.width).weight(.bold))
  }
}
