//
//  Stream.swift
//  Stream
//
//  Created by Alex on 26/09/2021.
//

import CoreStore
import Defaults
import SwiftUI

extension V1 {
  class Stream: CoreStoreObject, AbstractEntity, Reorderable, ImportableUniqueObject,
                ImportableModel,
                LazyStream, Streamable
  {
    
    static var primaryKey = "stream_id"
    
    typealias EntityType = Stream
    
    @Field.Stored("id")
    var id: String = ""
    
    @Field.Stored("stream_id")
    var stream_id: Int64 = 0
    
    @Field.Stored("category_id")
    var category_id: Int64 = 0
    
    @Field.Stored("num")
    var num: Int64 = 0
    
    @Field.Stored("name")
    var name: String = ""
    
    @Field.Stored("stream_type")
    var stream_type: String = ""
    
    @Field.Stored("epg_channel_id")
    var epg_channel_id: String = ""
    
    @Field.Stored("stream_icon")
    var stream_icon: String = ""
    
    @Field.Stored("is_adult")
    var is_adult: Bool = false
    
    @Field.Relationship("activity", inverse: \.$stream)
    var activity: Activity?
    
    typealias ImportSource = [String: Any]
    
    class var orderBy: OrderBy<Stream> {
      OrderBy([
        NSSortDescriptor(
          key: "name",
          ascending: true,
          selector: #selector(NSString.localizedStandardCompare)
        )
      ])
    }
    
    static var currentIds: [String] = [""]
    
    static var clearQuery: Where<Stream> {
      guard let ids = currentIds as NSArray? else {
        return Where<Stream>(NSPredicate(value: false))
      }
      guard ids.count > 0 else {
        return Where<Stream>(NSPredicate(value: false))
      }
      return Where<Stream>(NSPredicate(format: "NONE id IN %@", ids))
    }
    
    func loadData(from source: [String: Any]) {
      num = Self.asInt64(data: source, key: "num")
      stream_id = Self.asInt64(data: source, key: "stream_id")
      name = Self.asString(data: source, key: "name")
      category_id = Self.asInt64(data: source, key: "category_id")
      stream_type = Self.asString(data: source, key: "stream_type")
      epg_channel_id = Self.asString(data: source, key: "epg_channel_id")
      stream_icon = Self.asString(data: source, key: "stream_icon")
      is_adult = Self.asBool(data: source, key: "is_adult")
      id = stream_id.string
    }
    
    static func uniqueID(
      from source: [String: Any],
      in transaction: BaseDataTransaction
    ) throws -> String? {
      return self.asInt64(data: source, key: Self.primaryKey).string
    }
    
    func update(from source: [String: Any], in transaction: BaseDataTransaction) throws {
      self.loadData(from: source)
      Self.currentIds.append(id)
    }
    
    func didInsert(
      from data: [String: Any],
      in transaction: BaseDataTransaction
    )
    throws
    {
      self.loadData(from: data)
      Self.currentIds.append(id)
      if let stream_activity = try transaction.fetchOne(
        From<Activity>(),
        Where<Activity>("stream_id = %d", stream_id)
      ) {
        activity = stream_activity
      }
    }
    
    class func doImport(
      json: [[String: Any]],
      onComplete: @escaping (AsynchronousDataTransaction.Result<Void>) -> Void
    ) async throws {
      return dataStack.perform(
        asynchronous: { transaction -> Void in
          self.currentIds = []
          let _ = try! transaction.importUniqueObjects(
            Into<Stream>(),
            sourceArray: json
          )
        },
        completion: { r in
          onComplete(r)
        }
      )
    }
    
    var orderElement: Int64 {
      stream_id
    }
    
    typealias OrderElement = Int64
    
    var title: String {
      name.withoutHtmlTags()
    }
    
    var url: URL {
      API.Endpoint.Stream(stream_id)
    }
    
    var icon: URL {
      API.Endpoint.Icon(id: stream_id, epg: epg_channel_id)
    }
    
    var isPlaying: Bool {
      Player.instance.stream.id == self.id
    }
    
    var isAdult: Bool {
      is_adult || category_id == 366
    }
    
    static func needUpdate() -> Bool {
      let updated = Defaults[.scheduleUpdated]
      let res = !updated.isCloseTo(precision: 2.hours.timeInterval)
      logger.debug(">> streams needs update \(res) \(updated)")
      return res
    }
    
  }
}
