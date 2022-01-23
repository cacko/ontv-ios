//
//  ContentView.swift
//  tashak
//
//  Created by Alex on 16/09/2021.
//

import CoreStore
import SwiftUI

struct ControlItemView: View {

  @ObservedObject var player = Player.instance

  private var note: Notification.Name!
  private var object: Any?
  private let icon: ContentToggleIcon!
  private let image: String!
  private var hint: String!
  private var size: Double = 0

  func onClick() {
    guard note != nil else {
      return
    }
    player.controlsState = .visible
    NotificationCenter.default.post(name: note, object: object)
  }

  init(
    icon: ContentToggleIcon,
    note: Notification.Name,
    obj: Any? = nil,
    hint: String? = "",
    size: Double? = nil
  ) {
    self.note = note
    object = obj
    self.icon = icon
    self.hint = hint
    self.image = nil
    self.size = size ?? player.iconSize.width
  }

  init(
    image: String,
    note: Notification.Name,
    obj: Any? = nil,
    hint: String = "",
    size: Double? = nil
  ) {
    self.image = image
    self.hint = hint
    self.icon = nil
    self.note = note
    self.size = size ?? player.iconSize.width + 10
    object = obj
  }

  var body: some View {
    Button(action: {
      onClick()
    }) {
      if icon != nil {
        ControlSFSymbolView(icon: icon, width: size)
      }
      else {
        Image(image)
          .resizable()
          .frame(
            width: CGFloat(size),
            height: CGFloat(size),
            alignment: .center
          )
      }
    }
    .buttonStyle(.plain)
    .help(hint)
  }
}

extension ToggleViews {

  struct AlwaysOnControlsView: View {

    @ObservedObject var player = Player.instance

    var body: some View {
      ControlItemView(
        image: player.vendor.icon,
        note: Notification.Name.vendorToggle,
        hint: player.vendor.hint
      )
      ControlItemView(
        icon: .streams,
        note: Notification.Name.contentToggle,
        obj: ContentToggle.streams,
        hint: "Streams"
      )
      if player.stream != nil {
        ControlItemView(
          icon: .category,
          note: Notification.Name.contentToggle,
          obj: ContentToggle.category,
          hint: "Category streams"
        )
        ControlItemView(
          icon: .next,
          note: Notification.Name.navigate,
          obj: AppNavigation.next,
          hint: "Next stream"
        )
        ControlItemView(
          icon: .previous,
          note: Notification.Name.navigate,
          obj: AppNavigation.previous,
          hint: "Previous stream"
        )
      }
    }
  }

  struct EPGControlsView: View {
    @ObservedObject var player = Player.instance
    @ObservedObject var api = API.Adapter

    var body: some View {
      if api.epgState == .ready {
        if player.epgId.count > 0 {
          ControlItemView(
            icon: .guide,
            note: .contentToggle,
            obj: ContentToggle.guide,
            hint: "Show programme for the stream"
          )
        }
        ControlItemView(
          icon: .epglist,
          note: .contentToggle,
          obj: ContentToggle.epglist,
          hint: "Show programmes for all streams"
        )
        ControlItemView(
          icon: .activityepg,
          note: .contentToggle,
          obj: ContentToggle.activityepg,
          hint: "Show programme for recently opened streams"
        )
      }
    }
  }

  struct HistoryControlsView: View {
    @ObservedObject var player = Player.instance
    @ObservedObject var recent: Provider.Stream.RecentStreams = Provider.Stream.RecentItems

    var body: some View {
      if player.stream != nil {
        ControlItemView(
          icon: .restart,
          note: Notification.Name.reload
        )
      }
      //      if recent.canGoBack {
      //        ControlItemView(
      //          icon: .history_arrow,
      //          note: Notification.Name.recent,
      //          obj: AppNavigation.previous,
      //          hint: "Previous stream",
      //          size: Theme.Font.Size.base
      //        ).rotationEffect(.degrees(180))
      //      }
      //      if recent.canGoForward {
      //        ControlItemView(
      //          icon: .history_arrow,
      //          note: Notification.Name.recent,
      //          obj: AppNavigation.next,
      //          hint: "Next stream ",
      //          size: Theme.Font.Size.base
      //        )
      //      }
    }
  }

  struct PlayerControlsView: View {
    @ObservedObject var player = Player.instance

    func volumeStage(stage: Int) -> ContentToggleIcon {
      switch stage {
      case 1:
        return ContentToggleIcon.volumeStage1
      case 2: return ContentToggleIcon.volumeStage2
      case 3: return ContentToggleIcon.volumeStage3
      default:
        return ContentToggleIcon.isMutedOn
      }
    }

    var body: some View {
      ControlItemView(
        icon: player.isMuted
          ? ContentToggleIcon.isMutedOn : volumeStage(stage: player.volumeStage),
        note: Notification.Name.toggleAudio,
        hint: "Toggle audio"
      )
      ControlItemView(
        icon: .settings,
        note: Notification.Name.contentToggle,
        obj: ContentToggle.settings,
        hint: "Toggle audio"
      )
    }
  }

  struct StreamControlsView: View {
    @ObservedObject var ticker = LivescoreStorage.events
    @ObservedObject var api = API.Adapter

    var body: some View {
      if api.scheduleState == .ready {
        ControlItemView(
          icon: .schedule,
          note: Notification.Name.contentToggle,
          obj: ContentToggle.schedule,
          hint: "TheSportsDb Schedule"
        )
      }
      ControlItemView(
        icon: .livescores,
        note: Notification.Name.contentToggle,
        obj: ContentToggle.livescores,
        hint: "Livescores"
      )
      if ticker.tickerAvailable {
        ControlItemView(
          icon: .livescoreticler,
          note: Notification.Name.contentToggle,
          obj: ContentToggle.livescoresticker,
          hint: "Livescore Ticker"
        )
      }
      if api.streamsState == .ready {
        ControlItemView(
          icon: .search,
          note: Notification.Name.contentToggle,
          obj: ContentToggle.search,
          hint: "Search for whatever"
        )
        ControlItemView(
          icon: .bookmark,
          note: Notification.Name.contentToggle,
          obj: ContentToggle.bookmarks,
          hint: "Open bookmarks"
        )
      }
    }
  }

  struct ControlsView: View {
    @ObservedObject var player = Player.instance
    @ObservedObject var api = API.Adapter
    var body: some View {
      if player.controlsState != .hidden && api.inProgress == false && api.loggedIn {
        VStack {
          HStack {
            HistoryControlsView()
            Spacer()
            PlayerControlsView()
          }.padding().opacity(0.6)
          Spacer()
          HStack(alignment: .center, spacing: 2) {
            Spacer()
            HStack {
              AlwaysOnControlsView()
              EPGControlsView()
              StreamControlsView()
            }
            .padding()
            .background(
              player.controlsPosition == .center ? .clear : Theme.Color.Background.controls
            )
            .cornerRadius(10)
            Spacer()
          }.background(
            player.controlsPosition == .center
              ? Theme.Color.Background.header
              : .linearGradient(colors: [.clear], startPoint: .top, endPoint: .bottom)
          ).padding()

          if player.controlsPosition == .center {
            Spacer()
          }
        }
      }
    }
  }
}
