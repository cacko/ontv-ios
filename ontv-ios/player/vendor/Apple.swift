////
////  Player.swift
////  Player
////
////  Created by Alex on 17/09/2021.
////

import AVFoundation
import AVKit
import Combine
import Defaults
import SwiftUI

class PlayerAV: AbstractPlayer {
  
  let controller: Player
  
  var player: AVPlayer!
  
  var playerLayer: AVPlayerLayer!
  
  var media: AVPlayerItem!
  
  let center = NotificationCenter.default
  let mainQueue = OperationQueue.main
  
  var playerItemContext = 0
  
  override var isMuted: Bool {
    get {
      self.player.isMuted
    }
    set {
      self.player.isMuted.toggle()
    }
  }
  
  override var volume: Float {
    get {
      self.player.volume * 100
    }
    set {
      self.player?.volume = max(0, min(newValue / 100, 1))
    }
  }
  
  private var initialised: Bool = false
  
  override class var vendor: VendorInfo {
    get {
      VendorInfo(
        icon: "avfoundation",
        hint: "AVFoundation",
        id: .avfoundation,
        features: [.volume]
      )
    }
    set {}
  }
  
  let requiredAssetKeys = [
    "playable",
    "availableMetadataFormats",
    "metadata",
    "tracks",
  ]
  
  required init(
    _ controller: Player
  ) {
    self.controller = controller
    super.init(controller)
  }
  
  override func initView(_ view: VideoView) {
    player = AVPlayer()
    playerLayer = AVPlayerLayer(player: player)
    playerLayer.frame = view.frame
    playerLayer.minificationFilter = .nearest
    playerLayer.magnificationFilter = .nearest
    playerLayer.contentsGravity = .resizeAspectFill
    playerLayer.videoGravity = .resizeAspect
    view.layer.addSublayer(playerLayer)
  }
  
  override func deInitView() {
    player.pause()
    player.replaceCurrentItem(with: nil)
    player = nil
    playerLayer.removeFromSuperlayer()
  }
  
  override func play(_ stream: Stream) {
    guard let media = getMedia(stream) else {
      return self.onError(PlayerError(id: .trackFailed, msg: "Cannot play track"))
    }
    self.media = media
    self.player.replaceCurrentItem(with: self.media)
    self.player.play()
    
  }
  
  private func getMedia(_ stream: Stream) -> AVPlayerItem? {
    try? self.resetMedia()
    let media = AVPlayerItem(
      asset: AVAsset(url: stream.url),
      automaticallyLoadedAssetKeys: requiredAssetKeys
    )
    media.addObserver(
      self,
      forKeyPath: #keyPath(AVPlayerItem.status),
      options: [.old, .new],
      context: &playerItemContext
    )
    return media
  }
  
  
  private func resetMedia() throws {
    guard self.media != nil else {
      throw PlayerError(id: .null, msg: "alabala")
    }
    self.media.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
    self.media = nil
  }
  
  override func stop() {
    self.player.pause()
    try? self.resetMedia()
    self.controller.onStopPlaying()
  }
  
}
