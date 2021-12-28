//
//  Category.swift
//  Category
//
//  Created by Alex on 10/10/2021.
//

import CoreStore
import Foundation

extension V1 {
  class Category: CoreStoreObject, AbstractEntity, LazyStreams, ImportableUniqueObject,
                  ImportableModel
  {
    
    typealias EntityType = Category
    
    static let expiresIn: TimeInterval = TimeInterval(0)
    
    @Field.Stored("id")
    var id: String = ""
    
    @Field.Stored("category_id")
    var category_id: Int64 = 0
    
    @Field.Stored("parent_id")
    var parent_id: Int64 = 0
    
    @Field.Stored("category_name")
    var category_name: String = ""
    
    var title: String {
      self.category_name
    }
    
    var startTime: Date {
      Date()
    }
    
    var hasExpired: Bool {
      false
    }
    
    static var streamsCache: [String: [Stream]] = [:]
    
    class var primaryKey: String {
      "category_id"
    }
    
    static func uniqueID(
      from source: [String: Any],
      in transaction: BaseDataTransaction
    ) throws -> Int64? {
      return self.asInt64(data: source, key: uniqueIDKeyPath)
    }
    
    static var currentIds: [String] = []
    
    static var clearQuery: Where<Category> {
      guard let ids = currentIds as NSArray? else {
        return Where<Category>(NSPredicate(value: false))
      }
      guard ids.count > 0 else {
        return Where<Category>(NSPredicate(value: false))
      }
      return Where<Category>(NSPredicate(format: "NONE id IN %@", ids))
    }
    
    static func uniqueID(
      from source: [String: Any],
      in transaction: BaseDataTransaction
    ) throws -> String? {
      Self.asInt64(data: source, key: "category_id").string
    }
    
    func loadData(from source: [String: Any]) {
      category_name = Self.asString(data: source, key: "category_name")
      category_id = Self.asInt64(data: source, key: "category_id")
      parent_id = Self.asInt64(data: source, key: "parent_id")
      id = category_id.string
    }
    
    func update(from source: [String: Any], in transaction: BaseDataTransaction) throws {
      self.loadData(from: source)
      Self.currentIds.append(id)
    }
    
    func didInsert(from data: [String: Any], in transaction: BaseDataTransaction) throws {
      self.loadData(from: data)
      Self.currentIds.append(id)
    }
    
    class func doImport(
      json: [[String: Any]],
      onComplete: @escaping (AsynchronousDataTransaction.Result<Void>) -> Void
    ) async throws {
      
      dataStack.perform(
        asynchronous: { transaction -> Void in
          let _ = try! transaction.importUniqueObjects(
            Into<Category>(),
            sourceArray: json
          )
        },
        completion: { r in
          Self.streamsCache = [:]
          onComplete(r)
        }
      )
    }
    
    class var orderBy: OrderBy<Category> {
      OrderBy([
        NSSortDescriptor(
          key: "category_name",
          ascending: true,
          selector: #selector(NSString.localizedStandardCompare)
        )
      ])
    }
    
    var Streams: [LazyStream] {
      if !Self.streamsCache.keys.contains(id) {
        let predicate = NSPredicate(format: "category_id = %@", id)
        Self.streamsCache[id] = Stream.find(Where<Stream>(predicate), Stream.orderBy)
      }
      return Self.streamsCache[id] ?? []
    }
  }
}
