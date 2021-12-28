//
//  LiveBackground.swift
//  craptv
//
//  Created by Alex on 27/10/2021.
//

import Foundation
import SwiftUI

struct LiveStateBackground: ViewModifier {

  private let colors: [Color] = [
    Theme.Color.State.off,
    Theme.Color.State.live,
  ]

  @State var state: Bool = false

  func body(content: Content) -> some View {
    content.background(colors[state.intValue])
  }

}

extension View {

  func liveStateBackground(state: Bool) -> some View {
    modifier(
      LiveStateBackground(state: state)
    )
  }
}
