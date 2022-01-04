//
//  PressActions.swift
//  craptv
//
//  Created by Alex on 27/10/2021.
//

import Foundation
import SwiftUI

struct ListActions: ViewModifier {
  func body(content: Content) -> some View {
    content
      .simultaneousGesture(
        DragGesture(minimumDistance: 10)
          .onChanged { gesture in }
          .onEnded { gesture in }
          .exclusively(
            before:
              TapGesture()
              .onEnded { _ in onPress() }
          )
      )
  }
  var onPress: () -> Void
}

extension View {
  func pressAction(
    _ onPress: @escaping (() -> Void)
  ) -> some View {
    modifier(
      ListActions(
        onPress: { onPress() }
      )
    )
  }
}
