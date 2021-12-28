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
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {

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
  
  func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.landscape
  }

  func application(
    _ app: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    let screenSize: CGRect = UIScreen.main.bounds
    player.screenSize = CGSize(width: screenSize.height, height: screenSize.width)
    player.iconSize = CGSize(width: screenSize.height / 16, height: screenSize.height / 16)
    observe(app)
    Task.init {
      await API.Adapter.login()
    }

    let center = NotificationCenter.default
    let mainQueue = OperationQueue.main

    center.addObserver(
      forName: UIApplication.willResignActiveNotification,
      object: nil,
      queue: mainQueue
    ) { _ in
      guard self.player.state == .playing else {
        self.player.stop()
        return
      }
      self.player.pause()
    }

    center.addObserver(
      forName: UIApplication.willEnterForegroundNotification,
      object: nil,
      queue: mainQueue
    ) { _ in
      guard self.player.state == .paused else {
        return
      }
      self.player.resume()
    }

    return true
  }
}
