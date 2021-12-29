//
//  AppDelegate.swift
//  AppDelegate
//
//  Created by Alex on 04/10/2021.
//

import CoreStore
import Defaults
import Foundation
import SwiftUI

class AppDelegate: UIResponder, UIApplicationDelegate {

  var fixedRatio = CGSize(width: 1680, height: 1050)

  var initAppSize = CGSize(width: 800, height: 450)

  var lastOffset: CGFloat = 1.0

  var player: Player

  var menu: UIMenu!

  var fadeTask: DispatchWorkItem!

  var window: UIWindow?

  override init() {
    player = Player.instance
    player.volume = Defaults[.volume]
    Task.init {
      await API.Adapter.login()
    }
    super.init()
  }

  func application(
    _ app: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    let screenSize: CGRect = UIScreen.main.bounds
    player.screenSize = CGSize(width: screenSize.height, height: screenSize.width)
    player.iconSize = CGSize(width: screenSize.height / 14, height: screenSize.height / 14)
    observe(app)
    Task.init {
      await API.Adapter.login()
    }
    return true
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    guard player.state == .paused else {
      return
    }
    player.pause()
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    guard player.state == .playing else {
      player.stop()
      return
    }
    player.resume()
  }
}
