//
//  Streams.swift
//  Streams
//
//  Created by Alex on 15/10/2021.
//

import CoreStore
import Foundation



enum LivescoreStorage {
  
  static var active: [ContentToggle] = []
  static var timer: DispatchSourceTimer = DispatchSource.makeTimerSource()
  
  static var timerState: TimerState = .none
  
  static let events = Events()
  
  static func enable(_ content: ContentToggle) {
    guard active.contains(content) == false else {
      return
    }
    active.append(content)
    switch content {
    case .livescoresticker:
      events.active = true
    default:
      break
    }
    
    guard active.count > 0 else {
      return
    }
    
    guard timerState != .active else {
      return
    }
    
    startTimer()
  }
  
  static func disable(_ content: ContentToggle) {
    guard active.contains(content) else {
      return
    }
    active.removeAll(where: { $0 == content })
    switch content {
    case .livescoresticker:
      events.active = false
    default:
      break
    }
    guard timerState == .active else {
      return
    }
    guard active.isEmpty else {
      return
    }
    stopTimer()
  }
  
  static func startTimer() {
    
    if timerState == .none {
      timer.schedule(deadline: .now(), repeating: .seconds(60))
      timer.setEventHandler {
        Task.detached {
          try await API.Adapter.updateLivescore()
        }
      }
      timer.activate()
      timerState = .active
      return
    }
    
    guard timerState == .suspended else {
      return
    }
    timer.resume()
    timerState = .active
  }
  
  static func stopTimer()
  {
    
    guard timerState == .active else {
      return
    }
    
    timer.suspend()
    timerState = .suspended
  }
}

extension StorageProvider where EntityType == Livescore {
  
  static var dataStack: DataStack {
    CoreStoreDefaults.dataStack
  }
  
  static var center: NotificationCenter {
    NotificationCenter.default
  }
  
  static var mainQueue: OperationQueue {
    OperationQueue.main
  }
  
  func observe() {
  }
  
  func fetch() {
    
  }
  
  func update() {
    
  }
  
  func onChangeStream(stream: Stream) {}
}
