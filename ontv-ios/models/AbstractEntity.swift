//
//  AbstractModel.swift
//  AbstractModel
//
//  Created by Alex on 10/10/2021.
//

import CoreStore
import Foundation

protocol AbstractEntity {
  
  associatedtype EntityType: CoreStoreObject
  
  static var orderBy: OrderBy<EntityType> { get }
  
  static var primaryKey: String { get }
  
}

extension AbstractEntity {
  
  static var api: API.ApiAdapter {
    API.Adapter
  }
  
  static var dataStack: DataStack {
    CoreStoreDefaults.dataStack
  }
  
  static func get(_ id: Int64) -> EntityType? {
    Self.findOne(
      Where<EntityType>(NSPredicate(format: "\(primaryKey) = %@", String(id)))
    )
  }
  
  static func getAll() -> [EntityType] {
    do {
      return try dataStack.fetchAll(From<EntityType>().orderBy(orderBy))
    }
    catch {
      return []
    }
  }
  
  static func find(_ fetchClauses: FetchClause...) -> [EntityType] {
    do {
      return try dataStack.fetchAll(From<EntityType>(), fetchClauses)
    }
    catch {
      return []
    }
  }
  
  static func findOne(_ fetchClauses: FetchClause...) -> EntityType? {
    do {
      return try dataStack.fetchOne(
        From<EntityType>(),
        fetchClauses
      ) ?? nil
    }
    catch {
      return nil
    }
  }
  
  static var count: Int {
    do {
      return try dataStack.fetchCount(From<EntityType>())
    }
    catch let error {
      logger.error("\(error.localizedDescription)")
      return 0
    }
  }
  
  
static func delete(_ deleteClause: DeleteClause...) async throws {
    CoreStoreDefaults.dataStack.perform(
      asynchronous: { transaction -> Void in
        try transaction.deleteAll(
          From<EntityType>(),
          deleteClause
        )
      },
      completion: { _ in }
    )
  }
  
  static func deleteAll() {
    do {
      try CoreStoreDefaults.dataStack.perform(
        synchronous: { transaction -> Void in
          try transaction.deleteAll(
            From<EntityType>(),
            Where<EntityType>(NSPredicate(value: true))
          )
        }
      )
    }
    catch {
      logger.error("\(error.localizedDescription)")
    }
  }
}
