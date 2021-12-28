//
//  BookmarkView.swift
//  BookmarkView
//
//  Created by Alex on 01/10/2021.
//

import Foundation
import SwiftUI

struct ErrorView: View {
  @ObservedObject var player = Player.instance
  @ObservedObject var api = API.Adapter

  private let indicator = ProgressIndicator()

  func onState(_ state: PlayerState) {
    state == .opening ? indicator.start() : indicator.stop()
  }

  var body: some View {
    VStack(alignment: .center, spacing: 20) {
      Spacer()
      HStack {
        Spacer()
        Text(
          (api.state == .error ? api.error?.localizedDescription : player.error.msg) ?? ""
        )
        .font(Theme.Font.title)
        .textCase(.uppercase)
        if player.state == .retry {
          ProgressIndicator()
        }
        Spacer()
      }
      if player.state != .retry {
        Button(action: { NotificationCenter.default.post(name: .reload, object: nil) }) {
          Text("Retry").font(Theme.Font.title).textCase(.uppercase)
        }.buttonStyle(PushButtonStyle(.largeTitle))
      }
      Spacer()
    }
    .background(.black)
    .onChange(
      of: player.state,
      perform: { st in
        onState(st)
      }
    )
  }
}
