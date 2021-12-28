//
//  History.swift
//  History
//
//  Created by Alex on 15/10/2021.
//

import CoreStore
import Foundation
import SwiftDate

enum LivescoreStatus {
  static let fulltime = "FT"
  static let postponed = "PPD"
  static let empty = ""
  static let notstarted = "NS"
}

enum LivescoreState {
  case loading, ready
}

extension V1 {
  class Livescore: CoreStoreObject, AbstractEntity, ImportableUniqueObject, ImportableModel {
    
    typealias EntityType = Livescore
    
    class var primaryKey: String {
      "event_id"
    }
    
    @Field.Stored("id")
    var id: String = ""
    
    @Field.Stored("event_id")
    var event_id: Int64 = 0
    
    @Field.Stored("sport")
    var sport: String = ""
    
    @Field.Stored("league_id")
    var league_id: Int64? = 0
    
    @Field.Stored("league_name")
    var league_name: String? = ""
    
    @Field.Stored("home_team_id")
    var home_team_id: Int64 = 0
    
    @Field.Stored("away_team_id")
    var away_team_id: Int64 = 0
    
    @Field.Stored("home_team")
    var home_team: String = ""
    
    @Field.Stored("away_team")
    var away_team: String = ""
    
    @Field.Stored("status")
    var status: String = ""
    
    @Field.Stored("home_score")
    var home_score: Int = 0
    
    @Field.Stored("away_score")
    var away_score: Int = 0
    
    @Field.Stored("start_time")
    var start_time: Date = Date(timeIntervalSince1970: 0)
    
    @Field.Stored("sort")
    var sort: Double = 0.0
    
    @Field.Stored("in_ticker")
    var in_ticker: Int = 0
    
    @Field.Stored("score_changed")
    var score_changed: Int = 0
    
    static func uniqueID(
      from source: [String: Any],
      in transaction: BaseDataTransaction
    ) throws -> String? {
      Self.asString(data: source, key: "id")
    }
    
    func loadData(from source: [String: Any]) {
      id = Self.asString(data: source, key: "id")
      event_id = Self.asInt64(data: source, key: "idEvent")
      league_id = Self.asInt64(data: source, key: "idLeague")
      league_name = Self.asString(data: source, key: "strLeague")
      home_team_id = Self.asInt64(data: source, key: "idHomeTeam")
      away_team_id = Self.asInt64(data: source, key: "idAwayTeam")
      sport = Self.asString(data: source, key: "strSport")
      home_team = Self.asString(data: source, key: "strHomeTeam")
      away_team = Self.asString(data: source, key: "strAwayTeam")
      home_score = Self.asInt(data: source, key: "intHomeScore")
      away_score = Self.asInt(data: source, key: "intAwayScore")
      status = Self.asString(data: source, key: "strStatus")
      start_time = Self.asDate(data: source, key: "startTime")
      sort = Self.asDouble(data: source, key: "sort")
    }
    
    func update(from source: [String: Any], in transaction: BaseDataTransaction) throws {
      let old_score = "\(home_score.string):\(away_score.string)"
      self.loadData(from: source)
      let new_score = "\(home_score.string):\(away_score.string)"
      score_changed = (new_score != old_score).intValue
    }
    
    func didInsert(from data: [String: Any], in transaction: BaseDataTransaction) throws {
      self.loadData(from: data)
    }
    
    class func doImport(
      json: [[String: Any]],
      onComplete: @escaping (AsynchronousDataTransaction.Result<Void>) -> Void
    ) async throws {
      dataStack.perform(
        asynchronous: { transaction -> Void in
          let _ = try transaction.importUniqueObjects(
            Into<Livescore>(),
            sourceArray: json
          )
        },
        completion: { r in
          onComplete(r)
        }
      )
    }
    
    static var clearQuery: Where<Livescore> {
      let startOfDate = Calendar.current.startOfDay(for: Date())
      return Where<EntityType>(NSPredicate(format: "start_time < %@", startOfDate as NSDate))
    }
    
    @Field.Virtual(
      "viewStatus",
      customGetter: { (object, field) in
        let val = object.$status.value
        let isNotStarted = [LivescoreStatus.empty, LivescoreStatus.notstarted].contains(val)
        if isNotStarted {
          return "vs"
        }
        if val ~= "^\\d+$" {
          return "\(val)'"
        }
        return val
      }
    )
    var viewStatus: String
    
    @Field.Virtual(
      "startTime",
      customGetter: { (object, field) in
        let val = object.$status.value
        let isNotStarted = [
          LivescoreStatus.empty, LivescoreStatus.notstarted, LivescoreStatus.postponed,
        ].contains(val)
        if isNotStarted {
          return object.$start_time.value.HHMM
        }
        if val ~= "^\\d+$" {
          return "\(val)'"
        }
        return val
      }
    )
    var startTime: String
    
    @Field.Virtual(
      "inPlay",
      customGetter: { (object, field) in
        guard Date().isAfterDate(object.$start_time.value, granularity: Calendar.Component.minute)
        else {
          return false
        }
        guard ![LivescoreStatus.fulltime, LivescoreStatus.postponed].contains(object.$status.value)
        else {
          return false
        }
        guard min(object.$home_score.value, object.$away_score.value) > -1 else {
          return false
        }
        return true
      }
    )
    var inPlay: Bool
    
    class var orderBy: OrderBy<Livescore> {
      OrderBy<Livescore>(
        .descending("in_ticker"),
        .ascending("sort")
      )
    }
  }
}
