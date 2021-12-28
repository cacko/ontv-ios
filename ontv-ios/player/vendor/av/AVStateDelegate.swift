//
//  AVStateDelegate.swift
//  craptv
//
//  Created by Alex on 31/10/2021.
//

import AVFoundation
import Foundation


extension PlayerAV {
  
  override func observeValue(
    forKeyPath keyPath: String?,
    of object: Any?,
    change: [NSKeyValueChangeKey: Any]?,
    context: UnsafeMutableRawPointer?
  ) {
    
    guard context == &playerItemContext else {
      super.observeValue(
        forKeyPath: keyPath,
        of: object,
        change: change,
        context: context
      )
      return
    }
    
    guard keyPath == #keyPath(AVPlayerItem.status) else {
      return
    }
    
    let status: AVPlayerItem.Status
    guard let statusNumber = change?[.newKey] as? NSNumber else {
      return
    }
    status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
    
    switch status {
    case .readyToPlay:
      guard self.controller.state != PlayerState.playing else {
        return
      }
      self.loadMetadata()
      break
      // Player item is ready to play.
    case .failed:
      return self.onError(
        PlayerError(
          id: .trackFailed,
          msg: self.media.error?.localizedDescription ?? "kira mi qnko"
        )
      )
    case .unknown: break
    @unknown default: break
    }
  }
  
  func onError(_ error: PlayerError) {
    self.controller.error = error
    self.controller.state = .error
  }
}
