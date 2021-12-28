//
//  Streams.swift
//  Streams
//
//  Created by Alex on 15/10/2021.
//

import CoreStore
import Foundation

enum ScheduleStorage {
  
  static let events = Events()
}

extension StorageProvider where EntityType == Schedule {
  
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
    
    Self.center.addObserver(
      forName: .navigate,
      object: nil,
      queue: Self.mainQueue
    ) { note in
      self.onNavigate(note)
    }
    
    Self.center.addObserver(forName: .list_navigate, object: nil, queue: Self.mainQueue) {
      note in
      
      guard let action = note.object as? ListNavigation else {
        return
      }
      
      guard Player.instance.contentToggle == .schedule else {
        return
      }
      
      do {
        switch action {
        case .down:
          try self.selectNext()
        case .up:
          try self.selectPrevious()
        case .select:
          guard self.selected != nil else {
            return
          }
          NotificationCenter.default.post(name: .selectStream, object: self.selected.object)
          break
        default:
          logger.info("eat shit")
        }
      }
      catch let error {
        logger.error("\(error.localizedDescription)")
      }
    }
    
  }
  
  func fetch() {
    Task.init {
      if Schedule.needUpdate() {
        try await API.Adapter.updateSchedule()
      }
    }
  }
  
  func onChangeStream(stream: Stream) {}
}
