//
//  ToggleViews.swift
//  craptv
//
//  Created by Alex on 25/10/2021.
//

import Foundation
import SwiftUI

enum ToggleViews {
  static let hideControls: [ContentToggle] = [.activityepg, .epglist, .schedule, .search]
}

struct ToggleView: View {

  @ObservedObject var player = Player.instance
  @ObservedObject var apoi = API.Adapter

  var body: some View {
    GeometryReader { geo in
      ZStack {
        if player.contentToggle == .title {
          ToggleViews.TitleView()
        }
        if [.epglist, .activityepg].contains(player.contentToggle) {
          ToggleViews.EPGContentView()
            .frame(width: geo.size.width, height: geo.size.height)
            .background(.black.opacity(0.8))
        }
        if player.contentToggle == .guide {
          HStack {
            Spacer()
            ToggleViews.EPGView()
              .frame(width: geo.size.width * 0.5, height: geo.size.height)
              .background(.black.opacity(0.8))
          }
        }
        if player.contentToggle == .category {
          HStack {
            ToggleViews.CategoryView()
              .frame(width: geo.size.width * 0.5, height: geo.size.height)
              .background(.black.opacity(0.8))
            Spacer()
          }
        }
        ToggleViews.ScheduleView()
          .frame(width: geo.size.width, height: geo.size.height)
          .background(.black.opacity(0.8))
        ToggleViews.ControlsView()
        ToggleViews.BookmarkView()
        if player.contentToggle == .livescores {
          HStack {
            ToggleViews.LivescoreView()
              .frame(width: max(300, geo.size.width * 0.5), height: geo.size.height)
              .background(.black.opacity(0.8))
            Spacer()
          }
        }
      }
    }
  }
}
