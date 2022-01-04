//
//  ContentView.swift
//  tashak
//
//  Created by Alex on 16/09/2021.
//

import Defaults
import InAppSettingsKit
import SwiftUI

enum ContentToggle: Int, DefaultsSerializable {
  case guide, category, epglist, search, title, loading, controls, errror, activityepg, bookmarks,
    metadata, schedule, livescores, livescoresticker, none, settings
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
  case update = "network"
  case settings = "gear"
}

class AppSettingsViewController: IASKAppSettingsViewController, IASKSettingsDelegate {
  func settingsViewControllerDidEnd(_ settingsViewController: IASKAppSettingsViewController) {

  }

  func settingsViewController(
    _ settingsViewController: IASKAppSettingsViewController,
    buttonTappedFor specifier: IASKSpecifier
  ) {
    Task.init {
      await API.Adapter.login(username: Defaults[.username], password: Defaults[.password])
    }
  }
}

struct SettingsView: UIViewControllerRepresentable {
  typealias UIViewControllerType = AppSettingsViewController

  func makeUIViewController(
    context: UIViewControllerRepresentableContext<SettingsView>
  ) -> AppSettingsViewController {
    let controller = AppSettingsViewController()
    controller.showCreditsFooter = false
    controller.delegate = controller
    return controller
  }

  func updateUIViewController(
    _ uiViewController: AppSettingsViewController,
    context: UIViewControllerRepresentableContext<SettingsView>
  ) {

  }
}

struct ContentView: View {
  @ObservedObject var player = Player.instance
  @ObservedObject var api = API.Adapter
  @ObservedObject var ticker = LivescoreStorage.events

  let showSearch = Binding<Bool>(
    get: {
      Player.instance.contentToggle == .search
    },
    set: { _ in
    }
  )

  let showSettings = Binding<Bool>(
    get: {
      Player.instance.contentToggle == .settings && API.Adapter.state != .boot
    },
    set: { _ in
    }
  )

  var body: some View {
    ZStack(alignment: .center) {
      GeometryReader { geo in
        VideoViewRep()
          .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
          .aspectRatio(player.size.aspectSize, contentMode: .fit)
          .opacity(player.display && api.loggedIn ? 1 : 0)
          .onTapGesture(perform: {
            NotificationCenter.default.post(name: .onTap, object: nil)
          })
          .sheet(isPresented: showSearch) {
            SearchView()
          }
      }
      if api.inProgress {
        ApiInitProgress()
      }
      if [PlayerState.opening, PlayerState.buffering].contains(player.state) {
        LoadingView()
      }
      if player.state == .error || api.state == .error || player.state == .retry {
        ErrorView()
      }
      if ticker.tickerVisible {
        ToggleViews.LivescoreTickerView()
      }
      ToggleView()
    }
    .sheet(isPresented: showSettings) {
      NavigationView {
        SettingsView()
          .navigationBarTitle(Text("Settings"), displayMode: .inline)
      }.interactiveDismissDisabled(!api.loggedIn)
    }
    .background(
      Image("splash").resizable().aspectRatio(contentMode: .fill).opacity(
        (player.stream != nil) ? 0 : 0.5
      )
    ).background(.black)
  }
}
