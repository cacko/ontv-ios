//
//  HoverAction.swift
//  craptv
//
//  Created by Alex on 27/10/2021.
//

import CoreStore
import Foundation
import SwiftUI

struct TickerAction: ViewModifier {

  var state: Bool

  let colours: [LinearGradient] = [Theme.Color.Background.header, Theme.Color.State.ticker]

  func body(content: Content) -> some View {
    content
      .background(colours[state.intValue])
  }
}

extension View {
  func onTicker(state: Bool) -> some View {
    modifier(
      TickerAction(state: state)
    )
  }
}
