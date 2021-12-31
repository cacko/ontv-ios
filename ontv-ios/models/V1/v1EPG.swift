//
//  Epg.swift
//  Epg
//
//  Created by Alex on 05/10/2021.
//

import CoreStore
import Defaults
import Foundation
import SwiftUI

extension V1 {
  class EPG: CoreStoreObject, AbstractEntity, ImportableObject, ImportableModel {

    typealias EntityType = EPG

    class var primaryKey: String {
      "id"
    }

    static var clearQuery: Where<EntityType> {
      Where<EntityType>(NSPredicate(format: "stop < %@", Date() as NSDate))
    }

    @Field.Stored("id")
    var id: String = ""

    @Field.Stored("channel")
    var channel: String = ""

    @Field.Stored("title")
    var title: String = ""

    @Field.Stored("start")
    var start = Date()

    @Field.Stored("stop")
    var stop = Date()

    @Field.Stored("desc")
    var desc: String = ""

    @Field.Relationship("activity")
    var activity: Activity?

    var hashId: Int {
      var hasher = Hasher()
      hasher.combine(self.channel)
      hasher.combine("\(self.title).\(self.start).\(self.stop)")
      return hasher.finalize()
    }

    func loadData(from source: [String: Any]) {
      channel = Self.asString(data: source, key: "channel")
      title = Self.asString(data: source, key: "title")
      desc = Self.asString(data: source, key: "desc")
      start = Self.asDate(data: source, key: "start")
      stop = Self.asDate(data: source, key: "stop")
      id = hashId.string
    }

    private static var activities: [Activity]!
    private static var activityChannels: [String]!

    private func getActivity(tr: BaseDataTransaction, channel: String) -> Activity? {
      if Self.activities == nil {
        do {
          Self.activities = try tr.fetchAll(From<Activity>())
          Self.activityChannels = Self.activities.map { $0.stream?.epg_channel_id ?? "" }
        }
        catch {
          Self.activities = []
        }

      }
      guard Self.activityChannels.contains(channel) else {
        return nil
      }
      return Self.activities.first { $0.stream?.epg_channel_id == channel }
    }

    func didInsert(from data: [String: Any], in transaction: BaseDataTransaction) throws {
      self.loadData(from: data)
    }

    class func doImport(
      json: [[String: Any]],
      onComplete: @escaping (AsynchronousDataTransaction.Result<Void>) -> Void
    ) async throws {
      deleteAll()
      return dataStack.perform(
        asynchronous: { transaction -> Void in
          self.activities = nil
          let _ = try! transaction.importObjects(
            Into<EPG>(),
            sourceArray: json
          )
        },
        completion: { _ in
          dataStack.perform(
            asynchronous: { transaction -> Void in
              let now = Date()
              let stop = now.addingTimeInterval((60 * 60 * 25 * 2) * -1)
              try transaction.fetchAll(
                From<Activity>(),
                Where<Activity>("last_visit > %s", stop)
              ).forEach({ activity in
                guard let obj = transaction.edit(activity) else {
                  return
                }
                guard let stream_channel = obj.stream?.epg_channel_id else {
                  return
                }
                let predicates: [NSPredicate] = [
                  NSPredicate(format: "stop > %@", now as NSDate),
                  NSPredicate(format: "channel = %@", stream_channel),
                ]
                let query = Where<EPG>(
                  NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
                )
                let order = OrderBy<EPG>(
                  .ascending("channel"),
                  .ascending("start"),
                  .ascending("title")
                )
                let epgs = try transaction.fetchAll(
                  From<EPG>().where(query).orderBy(order)
                )
                obj.epgs = Set(epgs)
              })
            },
            completion: { r in
              onComplete(r)
            }
          )
        }
      )
    }

    static func needUpdate() -> Bool {
      let updated = Defaults[.epgUpdated]
      let res = !updated.isCloseTo(precision: 2.hours.timeInterval)
      logger.debug(">> EPG needs update \(res) \(updated)")
      return res
    }

    var isLive: Bool {
      let now = Date()
      return start.compare(now) == .orderedAscending && stop.compare(now) == .orderedDescending
    }

    var isPlaying: Bool {
      Player.instance.stream == self.stream
    }

    class var orderBy: OrderBy<EPG> {
      OrderBy([
        NSSortDescriptor(key: "start", ascending: true),
        NSSortDescriptor(
          key: "title",
          ascending: true,
          selector: #selector(NSString.localizedStandardCompare)
        ),
      ])
    }

    private var _stream: Stream?

    var stream: Stream? {
      guard self._stream != nil else {
        if let obj = Stream.findOne(Where<Stream>("epg_channel_id = %s", self.channel)) {
          self._stream = obj
        }
        return self._stream
      }
      return self._stream
    }

    var showTime: String {
      let formatter = DateFormatter()
      formatter.dateFormat = "HH:mm"
      return "\(formatter.string(from: start))\n\(formatter.string(from: stop))"
    }

    var startTime: String {
      let formatter = DateFormatter()
      formatter.dateFormat = "HH:mm"
      return formatter.string(from: start)
    }
  }
}
