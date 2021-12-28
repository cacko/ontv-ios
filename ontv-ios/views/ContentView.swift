//
//  ContentView.swift
//  tashak
//
//  Created by Alex on 16/09/2021.
//

import Defaults
import SwiftUI

enum ContentToggle {
  case guide, category, epglist, search, title, loading, controls, errror, activityepg, bookmarks,
    metadata, schedule, livescores, livescoresticker, none
}

enum ContentToggleIcon: String {
  case guide = "appletvremote.gen4"
  case category = "list.bullet.rectangle"
  case epglist = "play.tv"
  case search = "rectangle.and.text.magnifyingglass"
  case loading = "2"
  case title = "3"
  case controls = "4"
  case error = "5"
  case activityepg = "heart.text.square"
  case bookmarks = "7"
  case metadata = "8"
  case schedule = "calendar"
  case livescores = "sportscourt"
  case livescoreticler = "level"
  case next = "chevron.down"
  case previous = "chevron.up"
  case fullscreenOff = "arrow.down.right.and.arrow.up.left"
  case fullscreenOn = "arrow.up.left.and.arrow.down.right"
  case isMutedOn = "speaker.slash"
  case onTopOn = "square.stack.3d.up.fill"
  case onTopOff = "square.stack.3d.up.slash"
  case volumeStage1 = "speaker.wave.1"
  case volumeStage2 = "speaker.wave.2"
  case volumeStage3 = "speaker.wave.3"
  case close = "xmark"
  case bookmark = "bookmark"

}

struct ContentView: View {
  @ObservedObject var player = Player.instance
  @ObservedObject var api = API.Adapter
  @ObservedObject var ticker = LivescoreStorage.events
  @State private var hasBorder = false

  let showSearch = Binding<Bool>(
    get: {
      Player.instance.contentToggle == .search
    },
    set: { _ in
    }
  )

  var body: some View {
    GeometryReader { geo in
      ZStack(alignment: .center) {
        VideoViewRep()
          .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
          .aspectRatio(player.size.aspectSize, contentMode: .fill)
          .opacity(player.display ? 1 : 0)
          .background(.black).gesture(
            TapGesture(count: 1)
              .onEnded({ _ in
                NotificationCenter.default.post(name: .onTap, object: nil)
              })
          )
        //          .sheet(isPresented: showSearch) {
        //            SearchView()
        //              .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
        //              .cornerRadius(player.isFullscreen ? 0 : 5)
        //          }
        if [PlayerState.opening, PlayerState.buffering].contains(player.state) {
          LoadingView()
        }
        if player.state == .error || api.state == .error || player.state == .retry {
          ErrorView()
        }
        if api.loading != .loaded {
          ApiLoadingView()
        }
        if ticker.tickerVisible {
          ToggleViews.LivescoreTickerView()
        }
        ToggleView()
      }
      .onTapGesture(perform: {
        if [ContentToggle.guide, ContentToggle.category].contains(player.contentToggle) {
          NotificationCenter.default.post(name: .onTap, object: nil)
        }
      })
    }.colorScheme(.dark)
  }
}
