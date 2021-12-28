//
//  HoverAction.swift
//  craptv
//
//  Created by Alex on 27/10/2021.
//

import CoreStore
import Foundation
import SwiftUI

struct HideViewAction: ViewModifier {

  var state: Bool

  func body(content: Content) -> some View {
    content
      .opacity(state ? 0 : 1)
      .scaleEffect(state ? 0 : 1)
  }
}

extension View {
  func hideView(state: Bool) -> some View {
    modifier(
      HideViewAction(state: state)
    )
  }
}
