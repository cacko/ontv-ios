//
//  BookmarkView.swift
//  BookmarkView
//
//  Created by Alex on 01/10/2021.
//

import Foundation
import SwiftUI

extension ToggleViews {
  struct TitleView: View {
    @ObservedObject var player = Player.instance

    var body: some View {
      if player.contentToggle == .title {
        VStack {
          HStack(alignment: .center) {
            Spacer()
            if let stream = player.stream {
              StreamTitleView.IconView(stream.icon)
              Text(stream.title)
                .font(Theme.Font.title)
            }
            Spacer()
          }
          .padding()
          .background(Theme.Color.Background.header)
          Spacer()
        }
      }
    }
  }
}
