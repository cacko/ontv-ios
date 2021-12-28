//
//  FFMpegStateDelegate.swift
//  craptv
//
//  Created by Alex on 01/11/2021.
//

import Foundation
import KSPlayer

extension PlayerFFMpeg {
  func playerController(state: KSPlayerState) {
    switch state {
    case .bufferFinished:
      DispatchQueue.main.async {
        self.controller.display = true
        self.controller.onStartPlaying()
      }
      break
    case .error:
      return
    case .buffering:
      DispatchQueue.main.async {
        self.controller.state = .buffering
      }
      break
    default: break
    }
  }
  
  func playerController(currentTime: TimeInterval, totalTime: TimeInterval) {
    
  }
  
  func playerController(finish error: Error?) {
    
  }
  
  func playerController(maskShow: Bool) {
    
  }
  
  func playerController(action: PlayerButtonType) {
  }
  
  func playerController(bufferedCount: Int, consumeTime: TimeInterval) {
    
  }
}
