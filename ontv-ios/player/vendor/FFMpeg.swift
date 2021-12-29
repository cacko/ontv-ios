////
////  Player.swift
////  Player
////
////  Created by Alex on 17/09/2021.
////

import AVFoundation
import Combine
import Defaults
import KSPlayer
import SwiftUI

class PlayerFFMpeg: AbstractPlayer, PlayerControllerDelegate {

  let controller: Player

  var playerView: FFMpegPlayerView!

  var player: MediaPlayerProtocol!

  var media: KSPlayerResource!

  let center = NotificationCenter.default
  let mainQueue = OperationQueue.main

  var playerItemContext = 0

  override var isMuted: Bool {
    get {
      self.player?.isMuted ?? false
    }
    set {
      self.playerView?.playerLayer.player?.isMuted.toggle()
    }
  }

  override var volume: Float {
    get {
      return (self.player?.playbackVolume ?? 0) * 100
    }
    set {
      self.playerView?.playerLayer.player?.playbackVolume = max(0, min(newValue / 100, 1))
    }
  }

  private var initialised: Bool = false

  override class var vendor: VendorInfo {
    get {
      VendorInfo(
        icon: "ffmpeg",
        hint: "KSPlayer FFMMPEG",
        id: .ffmpeg,
        features: [.volume]
      )
    }
    set {}
  }

  required init(
    _ controller: Player
  ) {
    self.controller = controller
    KSPlayerManager.firstPlayerType = KSMEPlayer.self
    KSPlayerManager.topBarShowInCase = .none
    KSPlayerManager.logLevel = .panic
    KSPlayerManager.canBackgroundPlay = true
    KSPlayerManager.autoSelectEmbedSubtitle = false
    KSPlayerManager.enableBrightnessGestures = false
    KSPlayerManager.enablePlaytimeGestures = false
    KSPlayerManager.enablePortraitGestures = false
    KSPlayerManager.enableVolumeGestures = false
    KSPlayerManager.animateDelayTimeInterval = TimeInterval(5)
    super.init(controller)
  }

  override func initView(_ view: VideoView) {
    playerView = FFMpegPlayerView(controller)
    view.addSubview(playerView)
    playerView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      playerView.topAnchor.constraint(equalTo: view.readableContentGuide.topAnchor),
      playerView.leftAnchor.constraint(equalTo: view.leftAnchor),
      playerView.rightAnchor.constraint(equalTo: view.rightAnchor),
      playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }

  override func deInitView() {
    self.playerView.pause()
    self.playerView.resetPlayer()
    self.playerView.removeFromSuperview()
    self.playerView = nil
  }

  var options: KSOptions {
    let header = ["User-Agent": "ontv/\(Bundle.main.buildVersionNumber)"]
    let options = KSOptions()
    options.avOptions = ["AVURLAssetHTTPHeaderFieldsKey": header]
    options.preferredForwardBufferDuration = 1.0
    options.hardwareDecodeH264 = true
    options.hardwareDecodeH265 = true
    options.subtitleDisable = true
    return options
  }

  private func definition(_ stream: Stream) -> KSPlayerResourceDefinition {
    KSPlayerResourceDefinition(
      url: stream.url,
      definition: API.Adapter.username,
      options: options
    )
  }

  override func play(_ stream: Stream) {
    media = KSPlayerResource(definitions: [self.definition(stream)])
    playerView.set(resource: media)
    playerView.delegate = self
    playerView.play()
  }

  override func stop() {

  }

}
