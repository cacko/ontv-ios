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
    debugPrint(">>> livescore storage enable \(content)")
    guard active.contains(content) == false else {
      debugPrint(">>> livescore storage enable \(content) is already enabled")
      return
    }
    active.append(content)
    debugPrint(">>> livescore storage appended to active \(content)")
    switch content {
    case .livescoresticker:
      events.active = true
    default:
      break
    }
    
    guard active.count > 0 else {
      debugPrint(">>> livescore storage no active content not starting timer")
      return
    }
    
    guard timerState != .active else {
      return
    }
    
    startTimer()
  }
  
  static func disable(_ content: ContentToggle) {
    debugPrint(">>> livescore storage disable \(content)")
    
    guard active.contains(content) else {
      debugPrint(">>> livescore storage does not contain \(content)")
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
      debugPrint(">>> initialising timer")
      timer.schedule(deadline: .now(), repeating: .seconds(60))
      timer.setEventHandler {
        Task.detached {
          debugPrint(">>> livescore timer call api.updatelivescore")
          try await API.Adapter.updateLivescore()
        }
      }
      timer.activate()
      timerState = .active
      return
    }
    
    guard timerState == .suspended else {
      debugPrint(">>> livescore timer is not suspended, not resuming")
      return
    }
    timer.resume()
    timerState = .active
    debugPrint(">>> livescore timer resumed")
    
  }
  
  static func stopTimer()
  {
    
    guard timerState == .active else {
      debugPrint(">>> livescore timer not active, can't suspend")
      return
    }
    
    timer.suspend()
    timerState = .suspended
    debugPrint(">>> livescore timer suspended")
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
