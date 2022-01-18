//
//  NavigateAction.swift
//  craptv
//
//  Created by Alex on 27/10/2021.
//

import Foundation
import SwiftUI

struct ListHighlightAction: ViewModifier {

  @ObservedObject var player = Player.instance

  private let colors: [Color] = [
    Theme.Color.Hover.listItem.off,
    Theme.Color.Hover.listItem.on,
  ]

  private let stateColors: [Color] = [
    Theme.Color.State.off,
    Theme.Color.State.live,
  ]

  @State private var state: Bool = false
  @State private var background: Color = .clear

  @Binding var selectedId: String

  var itemId: String

  @State var highlightPlaying: Bool = false

  private var isPlaying: Bool {
    guard self.player.stream != nil else {
      return false
    }
    return self.player.stream.id == self.itemId
  }

  private var isSelected: Bool {
    self.selectedId == itemId
  }

  func onHighlight() {
    guard !isPlaying || !highlightPlaying else {
      return
    }
    background = colors[isSelected.intValue]
  }

  func onPlay(_ playId: String) {
    guard isPlaying && highlightPlaying else {
      return
    }
    background = stateColors[isPlaying.intValue]
  }

  func onAppear() {
    guard isPlaying && highlightPlaying else {
      return
    }
    background = stateColors[isPlaying.intValue]
  }

  func body(content: Content) -> some View {
    content
      .background(background)
      .onAppear(perform: { onAppear() })
      .onChange(of: selectedId, perform: { _ in onHighlight() })
  }
}

extension View {

  func listHighlight(
    selectedId: Binding<String>,
    itemId: String,
    highlightPlaying: Bool = false
  ) -> some View {
    modifier(
      ListHighlightAction(
        selectedId: selectedId,
        itemId: itemId,
        highlightPlaying: highlightPlaying
      )
    )
  }
}
