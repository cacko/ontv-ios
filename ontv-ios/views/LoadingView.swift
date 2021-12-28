//
//  BookmarkView.swift
//  BookmarkView
//
//  Created by Alex on 01/10/2021.
//

import Foundation
import Kingfisher
import SwiftUI

struct LoadingView: View {
  @ObservedObject var api = API.Adapter
  @ObservedObject var player = Player.instance
  private let indicator = ProgressIndicator()

  func onState(_ state: PlayerState) {
    state == .opening ? indicator.start() : indicator.stop()
  }

  var body: some View {
    VStack {
      Spacer()
      HStack(alignment: .center, spacing: 10) {
        Spacer()
        HStack(alignment: .center, spacing: 10) {
          if let stream = player.stream {
            StreamTitleView.IconView(stream.icon)
            Text(api.state == .loading ? "LOADING" : "\(stream.title )").font(
              Theme.Font.title
            )
          }
          indicator
        }
        Spacer()
      }.padding()
        .background(Theme.Color.Background.header)
      Spacer()
    }.onChange(
      of: player.state,
      perform: { st in
        onState(st)
      }
    )
  }
}
