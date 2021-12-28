//
//  StreamSearch.swift
//  craptv
//
//  Created by Alex on 29/10/2021.
//

import CoreStore
import Defaults
import Foundation
import SwiftDate
import SwiftUI

enum TickerPosition: Int {
  case top = 0
  case bottom = 1
}

extension LivescoreStorage {

  class Events: NSObject, ObservableObject, ObjectProvider, StorageProvider, AutoScrollProvider,
    TicketProvider
  {

    let api: API.ApiAdapter = API.Adapter

    typealias EntityType = Livescore

    var list: ListPublisher<EntityType>

    var selected: ObjectPublisher<Livescore>!

    var selectedId: String = ""

    var query: Where<Livescore> {
      get {
        Self.leagueQuery
      }
      set {}
    }
    var order: OrderBy<Livescore> = Livescore.orderBy
    var search: String = ""
    var state: ProviderState = .notavail
    var scrollTimer: DispatchSourceTimer = DispatchSource.makeTimerSource()
    var scrollTimerState: TimerState = .none
    var leagueObserver: DefaultsObservation!
    var scrollGenerator: LivescoreScrollGenerator
    @Published var scrollTo: String = ""
    @Published var scrollCount: Int = 0
    @Published var tickerPosition: TickerPosition = .top {
      didSet {
        Defaults[.tickerPosition] = self.tickerPosition.rawValue
      }
    }

    @Published var active: Bool = false {
      didSet {
        guard self.active else {
          return self.stopScrollTimer()
        }
        self.startScrollTimer()
      }
    }

    @Published var tickerVisible: Bool = false {
      didSet {
        DispatchQueue.main.async {
          guard self.tickerVisible else {
            return LivescoreStorage.disable(.livescoresticker)
          }
          LivescoreStorage.enable(.livescoresticker)
        }
      }
    }
    @Published var tickerAvailable: Bool = false

    func selectNext() throws {}

    func selectPrevious() throws {}

    func onNavigate(_ notitication: Notification) {}

    static var leagueQuery: Where<EntityType> {
      guard let leagues = Defaults[.leagues] as Set<Int>? else {
        return Where<Livescore>(NSPredicate(value: true))
      }
      return Where<Livescore>(NSPredicate(format: "league_id IN %@", leagues))
    }

    override init() {
      list = Self.dataStack.publishList(
        From<EntityType>()
          .where(Self.leagueQuery)
          .orderBy(order)
      )
      scrollGenerator = LivescoreScrollGenerator(list)
      scrollCount = scrollGenerator.count
      super.init()
      tickerVisible = scrollCount > 0
      tickerAvailable = scrollCount > 0
      tickerPosition = TickerPosition(rawValue: Defaults[.tickerPosition])!
      leagueObserver = Defaults.observe(keys: .leagues) {
        DispatchQueue.main.async {
          do {
            try self.list.refetch(From<EntityType>().where(self.query).orderBy(self.order))
          }
          catch let error {
            logger.error("\(error.localizedDescription)")
          }
        }
      }
    }

    func update(_ livescore: Livescore) {
      self.active = false
      Task.init {
        try await livescore.toggleTicker { _ in
          self.scrollGenerator.update()
          self.scrollCount = self.scrollGenerator.count
          self.tickerVisible = self.scrollCount > 0
          self.tickerAvailable = self.scrollCount > 0
          self.active = true
          guard self.tickerVisible else {
            return
          }
        }
      }
    }

    func get(_ id: String) -> ObjectPublisher<Livescore>? {

      guard id.count > 0 else {
        return nil
      }
      guard let ls = self.list.snapshot.first(where: { $0.$id == id }) else {
        return nil
      }
      guard let instance = ls.asPublisher(in: Livescore.dataStack) as ObjectPublisher<Livescore>?
      else {
        return nil
      }
      return instance
    }

    func timestampInList(_ timestamp: Date) -> Bool {
      guard self.list.snapshot.first(where: { $0.$start_time == timestamp }) != nil else {
        return false
      }
      return true
    }

    func eventInList(_ event_id: Int) -> Bool {
      guard event_id > 0 else {
        return false
      }
      guard self.list.snapshot.first(where: { $0.$event_id == event_id.int64 }) != nil else {
        return false
      }
      return true
    }

    func startScrollTimer() {
      if scrollTimerState == .none {
        self.scrollTimer.schedule(deadline: .now(), repeating: .seconds(5))
        self.scrollTimer.setEventHandler {
          guard self.api.livescoreState == .ready else {
            return
          }
          DispatchQueue.main.async {
            self.scrollTo = self.scrollGenerator.next()
          }
        }
        self.scrollTimer.activate()
        self.scrollTimerState = .active
        return
      }

      guard scrollTimerState == .suspended else {
        return
      }

      self.scrollTimer.resume()
      self.scrollTimerState = .active
    }

    func stopScrollTimer() {
      guard scrollTimerState == .active else {
        return
      }
      self.scrollTimer.suspend()
      self.scrollTimerState = .suspended
    }
  }
}
