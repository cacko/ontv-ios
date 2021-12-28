//
//  HoverAction.swift
//  craptv
//
//  Created by Alex on 27/10/2021.
//

import CoreStore
import Foundation
import SwiftUI

struct ScoreChangeActin: ViewModifier {

  var state: Bool

  let colours: [BlendMode] = [.normal, .lighten]

  func body(content: Content) -> some View {
    content.blendMode(colours[state.intValue])
  }
}

extension View {
  func onScoreChange(state: Bool) -> some View {
    modifier(
      ScoreChangeActin(state: state)
    )
  }
}
