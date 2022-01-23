//
//  FFMpegPlayerView.swift
//  craptv
//
//  Created by Alex on 01/11/2021.
//

import AVFoundation
import CoreMedia
import Foundation
import KSPlayer
import Libavformat
import UIKit

class FFMpegPlayerView: IOSVideoPlayerView {

  private let controller: Player

  init(
    _ controller: Player
  ) {
    self.controller = controller
    super.init(frame: UIScreen.main.bounds)
  }

  override func customizeUIComponents() {

    tapGesture.addTarget(self, action: #selector(tapGestureAction(_:)))
    tapGesture.numberOfTapsRequired = 1
    addGestureRecognizer(tapGesture)
    doubleTapGesture.addTarget(self, action: #selector(doubleTapGestureAction))
    doubleTapGesture.numberOfTapsRequired = 2
    tapGesture.require(toFail: doubleTapGesture)
    addGestureRecognizer(doubleTapGesture)

    navigationBar.isHidden = true
    toolBar.isHidden = true
    toolBar.timeSlider.isHidden = true
    toolBar.removeFromSuperview()
    loadingIndector.removeFromSuperview()
    seekToView.isHidden = true
    seekToView.removeFromSuperview()
    srtControl.view.removeFromSuperview()
    replayButton.isHidden = true
    replayButton.removeFromSuperview()
  }

  @objc open override func doubleTapGestureAction() {
    guard controller.controlsState == .always else {
      return
    }
    controller.controlsState = controller.controlsState != .hidden ? .hidden : .visible
  }

  @objc open override func tapGestureAction(_: UITapGestureRecognizer) {
    guard controller.controlsState == .always else {
      return
    }
    controller.controlsState = controller.controlsState != .hidden ? .hidden : .visible
  }

  override func player(layer _: KSPlayerLayer, finish error: Error?) {
    guard let error = error as Error? else {
      return
    }
    self.onError(PlayerError(id: .trackFailed, msg: error.localizedDescription))

  }

  override open func player(layer: KSPlayerLayer, state: KSPlayerState) {
    super.player(layer: layer, state: state)

    guard state == .bufferFinished, let player = layer.player else {
      return
    }

    guard let videoTrack = player.tracks(mediaType: .video).first as MediaPlayerTrack? else {
      return
    }

    DispatchQueue.main.async {
      self.controller.metadata.video = StreamInfo.Video(
        codec: videoTrack.codecType.string,
        resolution: videoTrack.naturalSize
      )
      self.controller.onMetadataLoaded()
    }

    guard let audioTrack = player.tracks(mediaType: .audio).first else {
      return
    }

    DispatchQueue.main.async {
      Player.instance.metadata.audio = StreamInfo.Audio(
        codec: audioTrack.codecType.description,
        channels: 2,
        rate: 44100
      )
    }
  }

  func onError(_ error: PlayerError) {
    DispatchQueue.main.async {
      self.controller.error = error
      self.controller.state = .error
    }
  }
}
