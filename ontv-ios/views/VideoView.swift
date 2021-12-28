//
//  VideoView.swift
//  VideoView
//
//  Created by Alex on 21/09/2021.
//

import AVFoundation
import Defaults
import SwiftUI
import UIKit

class VideoView: UIView {
  var player = Player.instance

  func postInit() {
    player.initView(self)

    let center = NotificationCenter.default
    let mainQueue = OperationQueue.main

    center.addObserver(forName: .vendorChange, object: nil, queue: mainQueue) { note in
      guard let renderer = note.object as? PlayVendor else {
        return
      }
      self.vendorChange(renderer)
    }

    center.addObserver(forName: .vendorToggle, object: nil, queue: mainQueue) {
      _ in self.vendorToggle()
    }
  }

  func vendorChange(_ vendor: PlayVendor) {
    Defaults[.vendor] = vendor
    self.player.switchVendor(vendor)
    self.player.initView(self)
    if let stream = self.player.stream {
      self.player.play(stream)
    }
  }

  func vendorToggle() {
    let vendors = self.player.availableVendors + self.player.availableVendors
    let newIdx = vendors.index(
      after: vendors.firstIndex(where: { $0.id == self.player.vendor.id })!
    )
    guard let nextRenderer = vendors[newIdx] as VendorInfo? else {
      fatalError()
    }
    NotificationCenter.default.post(name: .vendorChange, object: nextRenderer.id)
  }

  func initPlayer() {
    player.initView(self)
  }
}

struct VideoViewRep: UIViewRepresentable {

  typealias UIViewType = VideoView

  func makeUIView(context: Context) -> VideoView {
    let vv = VideoView(frame: UIScreen.main.bounds)
    vv.postInit()
    return vv
  }

  func updateUIView(_ uiView: VideoView, context: Context) {}

}
