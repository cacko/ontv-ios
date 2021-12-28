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

class FFMpegPlayerView: IOSVideoPlayerView {

  private let controller: Player

  init(
    _ controller: Player
  ) {
    self.controller = controller
    super.init(frame: .zero)
  }

  override func customizeUIComponents() {

    tapGesture.addTarget(self, action: #selector(tapGestureAction(_:)))
    tapGesture.numberOfTapsRequired = 1
    addGestureRecognizer(tapGesture)
//    panGesture.addTarget(self, action: #selector(panGestureAction(_:)))
//    addGestureRecognizer(panGesture)
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
  
  
  
  var hideCursorTask: DispatchWorkItem!
  
   func onTapProcess() {
    
    
    guard self.controller.controlsState != .always else {
      return
    }
    
    if ToggleViews.hideControls.contains(self.controller.contentToggle ?? .none) == false {
      self.controller.controlsState = .visible
    }
    
    let task = self.getHideCursorTask()
    
    guard controller.controlsState == .visible else {
      return
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: task)
  }
  
  private func getHideCursorTask() -> DispatchWorkItem {
    if self.hideCursorTask != nil {
      self.hideCursorTask.cancel()
    }
    self.hideCursorTask = DispatchWorkItem {
      guard self.controller.contentToggle != .search else {
        return
      }
      self.controller.controlsState = .hidden
      
    }
    return self.hideCursorTask
  }
  
//  @objc open override func doubleTapGestureAction() {
//    NotificationCenter.default.post(name: .onTap, object: nil)
//    isMaskShow = false
//  }
  
  @objc open override func tapGestureAction(_: UITapGestureRecognizer) {
    self.onTapProcess()
//    isMaskShow = false
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

    Player.instance.metadata.video = StreamInfo.Video(
      codec: videoTrack.codecType.description,
      resolution: videoTrack.naturalSize
    )

    DispatchQueue.main.async {
      Player.instance.size = videoTrack.naturalSize
      NotificationCenter.default.post(name: .fit, object: videoTrack.naturalSize)
    }

    guard let audioTrack = player.tracks(mediaType: .audio).first else {
      return
    }

    Player.instance.metadata.audio = StreamInfo.Audio(
      codec: audioTrack.codecType.description,
      channels: 2,
      rate: 44100
    )
    DispatchQueue.main.async {
      Player.instance.metadataState = .loaded
    }
  }

  func onError(_ error: PlayerError) {
    DispatchQueue.main.async {
      self.controller.error = error
      self.controller.state = .error
    }
  }
}
