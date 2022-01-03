//
//  EPGStorage.swift
//  EPGStorage
//
//  Created by Alex on 12/10/2021.
//

import Combine
import CoreStore
import Foundation
import SwiftUI

enum ActivityListToggleType {
  case state
}

class ActivityStorage {
  
  private static var _active: ContentToggle = .none
  
  static let activityepg = ActivityEPGList()
  
  static var active: ContentToggle {
    get {
      Self._active
    }
    set {
      Self._active = Self._active == newValue ? .none : newValue
      Player.instance.contentToggle = self._active
    }
  }
}

protocol AcitvityStorageProtocol {
  var query: Where<Activity> { get set }
  
  var order: OrderBy<Activity> { get set }
}

class ActivityStorageAbstract: NSObject, ObservableObject, AcitvityStorageProtocol {
  var query = Where<Activity>("1=0")
  
  var order = OrderBy<Activity>(
    .descending("last_visit"),
    .ascending("favourite"),
    .descending("visits")
  )
  
  @Published var list: ListPublisher<Activity>
  
  @Published var state: ProviderState = .notavail
  
  let dataStack = CoreStoreDefaults.dataStack
  
  let player = Player.instance
  
  var cancellables = Set<AnyCancellable>()
  
  override init() {
    self.list = self.dataStack.publishList(
      From<Activity>()
        .where(self.query)
        .orderBy(self.order)
    )
    super.init()
    self.postInit()
  }
  
  func postInit() {
    self.update()
  }
  
  func onChangeStream(stream: Stream) {
    
  }
  
  func fetch() {
    do {
      try self.list.refetch(
        From<Activity>()
          .where(self.query)
          .orderBy(self.order),
        sourceIdentifier: nil
      )
      self.state = .loaded
    }
    catch {
      logger.error("\(error.localizedDescription)")
    }
  }
  
  func update() {
    self.state = .loaded
    self.fetch()
  }
}
