//
//  StreamSearch.swift
//  craptv
//
//  Created by Alex on 29/10/2021.
//

import CoreStore
import Foundation
import SwiftDate

extension ScheduleStorage {
  
  class Events: NSObject, ObservableObject, StorageProvider {
    
    typealias EntityType = Schedule
    
    @Published var state: API.State = .notavail
    
    @Published var active: Bool = false
    
    var selectedId: String = "" {
      didSet {
        objectWillChange.send()
      }
    }
    
    @Published var search: String = "" {
      didSet {
        self.update()
      }
    }
    
    var query: Where<Schedule> = Where<Schedule>(
      NSPredicate(format: "timestamp > %@", Date() - 2.hours as CVarArg)
    )
    
    var order: OrderBy<Schedule> = Schedule.orderBy
    
    var list: ListPublisher<Schedule>
    
    var selected: ObjectPublisher<Schedule>! {
      didSet {
        objectWillChange.send()
      }
    }
    
    override init() {
      self.list = Self.dataStack.publishList(
        From<Schedule>()
          .sectionBy("timestamp")
          .where(self.query)
          .orderBy(self.order)
      )
      super.init()
      self.observe()
    }
    
    func observe() {
      Self.center.addObserver(forName: .updateschedule, object: nil, queue: Self.mainQueue) { _ in
        try? self.list.refetch(
          From<Schedule>()
            .sectionBy("timestamp")
            .where(self.query)
            .orderBy(self.order),
          sourceIdentifier: nil
        )
      }
    }
    
    func update() {
      self.fetch()
    }
    
    func onNavigate(_ notification: Notification) {
      logger.error("on navigate")
    }
    
    func selectNext() throws {
      logger.error("select next")
      
    }
    
    func selectPrevious() throws {
      logger.error("select previous")
    }
  }
}
