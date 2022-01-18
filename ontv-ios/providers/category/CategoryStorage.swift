//
//  Streams.swift
//  Streams
//
//  Created by Alex on 15/10/2021.
//

import CoreStore
import Foundation

enum CategoryStorage {
  
  static let list = List()
  
}

extension StorageProvider where EntityType == Category {
  
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
