//
//  NavigateAction.swift
//  craptv
//
//  Created by Alex on 27/10/2021.
//

import Foundation
import SwiftUI

struct NavigateAction: ViewModifier {
  private let colors: [Color] = [
    Theme.Color.State.off,
    Theme.Color.State.live,
  ]

  @Binding var selectedId: String

  @State var state: Bool = false

  var proxy: ScrollViewProxy

  func onSelect(_ id: String) {
    self.proxy.scrollTo(id, anchor: .center)
  }

  func body(content: Content) -> some View {
    content.onChange(
      of: selectedId,
      perform: { id in
        onSelect(id)
      }
    )
  }
}

extension View {

  func navigate(proxy: ScrollViewProxy, id: Binding<String>) -> some View {
    modifier(
      NavigateAction(selectedId: id, proxy: proxy)
    )
  }
}
