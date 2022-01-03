//
//  AppDelegate.swift
//  AppDelegate
//
//  Created by Alex on 04/10/2021.
//

import CoreStore
import Defaults
import Foundation
import InAppSettingsKit
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
    super.init()
  }

  func application(
    _ application: UIApplication,
    supportedInterfaceOrientationsFor window: UIWindow?
  ) -> UIInterfaceOrientationMask {
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
    
    center.addObserver(
      forName: UIApplication.willTerminateNotification,
      object: nil,
      queue: mainQueue
    ) { _ in
      self.player.stop()
      self.player.deinitView()
    }

    center.addObserver(
      forName: NSNotification.Name.IASKSettingChanged,
      object: nil,
      queue: mainQueue
    ) { (note: Notification) in

      guard let prefKey = (note.userInfo?.keys.first)! as? String else {
        return
      }

      guard prefKey.starts(with: "livescores_league_") else {
        return
      }

      if let id = Int(
        prefKey.replacingOccurrences(of: "livescores_league_", with: "")
      ) {
        var leagues = Defaults[.leagues]
        if note.userInfo?[prefKey] as! Int == 1 {
          leagues.insert(id)
        }
        else {
          leagues.remove(id)
        }
        Defaults[.leagues] = leagues
      }
    }
    return true
  }
}
