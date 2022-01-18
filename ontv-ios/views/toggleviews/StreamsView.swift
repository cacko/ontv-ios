//
//  StreamsView.swift
//  ontv-ios
//
//  Created by Alex on 18/01/2022.
//

import CoreStore
import Foundation
import SwiftUI

extension ToggleViews {

  struct StreamsView: View {

    struct CategoryRow: View {
      var category: ObjectPublisher<Category>
      @ObservedObject var categoryProvider = CategoryStorage.list
      @ObservedObject var streamProvider = StreamStorage.category

      func openCategory() {
        categoryProvider.selectedId = self.category.id ?? ""
        streamProvider.search = self.category.id ?? ""
      }

      var body: some View {
        Button(action: { openCategory() }) {
          HStack(alignment: .top) {
            Spacer()
            Text(category.category_name!)
              .font(Theme.Font.title)
              .lineLimit(1)
              .truncationMode(.tail)
              .multilineTextAlignment(.trailing)
          }.padding()
        }.buttonStyle(ListButtonStyle())
      }
    }

    struct StreamRow: View {
      var stream: ObjectPublisher<Stream>

      func openStream() {
        NotificationCenter.default.post(name: .selectStream, object: stream.object)
      }

      var body: some View {
        Button(action: { openStream() }) {
          HStack(alignment: .top) {
            StreamTitleView.TitleView(stream.icon!) {
              Text(stream.title!)
                .font(Theme.Font.programme)
                .lineLimit(1)
                .truncationMode(.tail)
                .multilineTextAlignment(.leading)
            }
            Spacer()
          }.padding()
        }.buttonStyle(ListButtonStyle())
      }
    }

    @ObservedObject var categoryProvider = CategoryStorage.list
    @ObservedObject var streamProvider = StreamStorage.category
    @ObservedObject var player = Player.instance
    @ObservedObject var api = API.Adapter

    private var buttonFont: Font = .system(size: 20, weight: .heavy, design: .monospaced)

    var body: some View {
      if player.contentToggle == .streams {
        VStack(alignment: .trailing, spacing: 0) {
          ContentHeaderView(
            title: "Streams",
            icon: ContentToggleIcon.streams,
            apiType: .streams
          )
          HStack(alignment: .top, spacing: 0) {
            ScrollingView {
              ListReader(categoryProvider.list) { snapshot in
                ForEach(sectionIn: snapshot) { section in
                  LazyVStack(alignment: .trailing, spacing: 0) {
                    ForEach(objectIn: section) { category in
                      LazyVStack(alignment: .trailing, spacing: 0) {
                        CategoryRow(category: category)
                          .id(category.id)
                          .listHighlight(
                            selectedId: $categoryProvider.selectedId,
                            itemId: category.id!,
                            highlightPlaying: true
                          )
                      }
                    }
                  }
                }
              }
            }
            ScrollingView {
              ListReader(streamProvider.list) { snapshot in
                ForEach(sectionIn: snapshot) { section in
                  ForEach(objectIn: section) { stream in
                    StreamRow(stream: stream)
                      .id(stream.id).listHighlight(
                        selectedId: $streamProvider.selectedId,
                        itemId: stream.id!,
                        highlightPlaying: true
                      )
                  }
                }
              }
            }
          }.background(Theme.Color.Background.header)
        }
      }
    }
  }

}
