//
//  History.swift
//  History
//
//  Created by Alex on 15/10/2021.
//

import CoreStore
import Foundation
import SwiftDate

extension V1 {
  class League: CoreStoreObject, AbstractEntity, ImportableUniqueObject, ImportableModel {
    
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
    
    static func uniqueID(
      from source: [String: Any],
      in transaction: BaseDataTransaction
    ) throws -> String? {
      Self.asString(data: source, key: "id")
    }
    
    func loadData(from source: [String: Any]) {
      id = Self.asString(data: source, key: "id")
      league_id = Self.asInt64(data: source, key: "idLeague")
      league_name = Self.asString(data: source, key: "strLeague")
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
        .ascending("league_name")
      )
    }
  }
}
