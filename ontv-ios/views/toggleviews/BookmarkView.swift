//
//  BookmarkView.swift
//  BookmarkView
//
//  Created by Alex on 01/10/2021.
//

import Foundation
import Kingfisher
import SwiftUI

extension ToggleViews {
  struct BookmarkView: View {
    @ObservedObject var player = Player.instance
    @ObservedObject var quickStreams = Provider.Stream.QuickStreams

    func onPress(_ s: QuickStream) {
      guard s.isValid else {
        return self.bookmark(s)
      }
      NotificationCenter.default.post(name: .selectStream, object: s.stream)
    }

    func bookmark(_ s: QuickStream) {
      Task.init {
        do {
          try await quickStreams.bookmark(s)
          NotificationCenter.default.post(name: .updatebookmarks, object: nil)
          player.contentToggle = .bookmarks
        }
        catch let error {
          logger.error("\(error.localizedDescription)")
        }
      }
    }

    var body: some View {
      if player.contentToggle == .bookmarks {
        VStack {
          Spacer()
          VStack {
            Text("Click to open or save if empty slot")
              .font(Theme.Font.programme)
              .shadow(color: .black, radius: 1, x: 1, y: 1)
              .textCase(.uppercase).onTapGesture(perform: {})
            HStack {
              Spacer()
              ForEach(quickStreams.streams, id: \.idx) { qs in
                Button(action: { onPress(qs) }) {
                  ZStack {
                    Text(String(qs.idx))
                      .foregroundColor(qs.isValid ? .gray : .primary)
                      .shadow(color: .black, radius: 1, x: 1, y: 1)
                    if let icon = qs.icon {
                      KFImage(icon)
                        .cacheOriginalImage()
                        .setProcessor(
                          DownsamplingImageProcessor(
                            size: .init(width: 80, height: 40)
                          )
                        ).opacity(0.5)
                    }
                  }
                  .padding()
                }.onTapGesture(perform: {})
                .highPriorityGesture(
                  TapGesture(count: 2)
                    .onEnded({ _ in
                      bookmark(qs)
                    })
                )
                .buttonStyle(CustomButtonStyle(Theme.Font.Bookmark.button))
                .cornerRadius(10)
              }
              Spacer()
            }
            Text("Double click to save on any slot")
              .font(Theme.Font.programme)
              .shadow(color: .black, radius: 1, x: 1, y: 1)
              .textCase(.uppercase)
          }.contentShape(Rectangle()).onTapGesture(perform: {})
          .padding()
          .background(Theme.Color.Background.header)
          Spacer()
        }.contentShape(Rectangle()).onTapGesture(perform: {
          player.contentToggle = ContentToggle.none
        })
      }
    }
  }
}
