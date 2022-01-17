//
//  Providers.swift
//  craptv
//
//  Created by Alex on 22/10/2021.
//

import CoreStore
import Foundation
import SwiftUI

enum TimerState {
  case none, active, suspended
}


protocol StorageProvider: ObservableObject {
  
  associatedtype EntityType: CoreStoreObject
  
  var list: ListPublisher<EntityType> { get set }
  var selected: ObjectPublisher<EntityType>! { get set }
  var selectedId: String { get set }
  var query: Where<EntityType> { get set }
  var order: OrderBy<EntityType> { get set }
  var search: String { get set }
  var active: Bool { get set }
  var state: API.State { get set }
  
  func selectNext() throws
  func selectPrevious() throws
  func onChangeStream(stream: Stream)
  func onNavigate(_ notitication: Notification)
  func update()
}

protocol ObjectProvider {
  associatedtype EntityType: CoreStoreObject
  var active: Bool { get set }
  func get(_ id: String) -> ObjectPublisher<EntityType>?
}

protocol AutoScrollProvider: ObservableObject {
  var scrollTo: String { get set }
  var scrollCount: Int { get set }
}

protocol TicketProvider: ObservableObject {
  var tickerVisible: Bool { get set }
}

enum Provider {
  enum Stream {}
  enum Actiity {}
  enum EPG {}
  enum Generator {}
  
  struct Error: CustomNSError, Identifiable, Equatable {
    var id: Errors
    
    enum Errors {
      case outOfBounds
      case unexpected
    }
    
    let msg: String
  }
}
