//
//  History.swift
//  History
//
//  Created by Alex on 15/10/2021.
//

import CoreStore
import Defaults
import Foundation
import SwiftDate

extension V1 {
  class League: CoreStoreObject, AbstractEntity, ImportableUniqueObject, ImportableModel, Updatable
  {

    typealias EntityType = League

    class var primaryKey: String {
      "id"
    }

    @Field.Stored("id")
    var id: String = ""

    @Field.Stored("league_id")
    var league_id: Int64 = 0

    @Field.Stored("league_name")
    var league_name: String = ""

    @Field.Stored("country_id")
    var country_id: Int64 = 0

    @Field.Stored("country_name")
    var country_name: String = ""

    @Field.Stored("sport_id")
    var sport_id: Int64 = 0

    @Field.Stored("sport_name")
    var sport_name: String = ""

    static func uniqueID(
      from source: [String: Any],
      in transaction: BaseDataTransaction
    ) throws -> String? {
      Self.asString(data: source, key: "id")
    }

    func loadData(from source: [String: Any]) {
      id = Self.asString(data: source, key: "id")
      league_id = Self.asInt64(data: source, key: "league_id")
      league_name = Self.asString(data: source, key: "league_name")
      country_id = Self.asInt64(data: source, key: "country_id")
      country_name = Self.asString(data: source, key: "country_name")
      sport_id = Self.asInt64(data: source, key: "sport_id")
      sport_name = Self.asString(data: source, key: "sport_name")
    }

    func update(from source: [String: Any], in transaction: BaseDataTransaction) throws {
      self.loadData(from: source)
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
            Into<EntityType>(),
            sourceArray: json
          )
        },
        completion: { r in onComplete(r) }
      )
    }

    class var orderBy: OrderBy<EntityType> {
      OrderBy<EntityType>(
        .ascending("country_name"),
        .ascending("league_name")
      )
    }

    static var needsUpdate: Bool {
      !Defaults[.leaguesUpdated].isCloseTo(precision: 2.minutes.timeInterval)
    }

    static var isLoaded: Bool {
      Defaults[.leaguesUpdated].timeIntervalSince1970 > 0
    }
  }
}
