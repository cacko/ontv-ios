//
//  ToggleViews.swift
//  craptv
//
//  Created by Alex on 25/10/2021.
//

import Foundation
import SwiftUI

enum ToggleViews {
  static let hideControls: [ContentToggle] = [
    .activityepg, .epglist, .schedule, .search
  ]
}
struct ToggleView: View {

  @ObservedObject var player = Player.instance
  @ObservedObject var apoi = API.Adapter

  var body: some View {
    GeometryReader { geo in
      ZStack {
        ToggleViews.TitleView()
        ToggleViews.EPGContentView()
          .frame(width: geo.size.width, height: geo.size.height)
          .background(.black.opacity(0.8))
        ToggleViews.EPGView()
        ToggleViews.CategoryView()
        ToggleViews.ScheduleView()
          .frame(width: geo.size.width, height: geo.size.height)
          .background(.black.opacity(0.8))
        ToggleViews.ControlsView()
        ToggleViews.BookmarkView()
        ToggleViews.LivescoreView()
      }
    }
  }
}
