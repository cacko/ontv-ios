//
//  History.swift
//  History
//
//  Created by Alex on 15/10/2021.
//

import CoreStore
import Foundation

extension V1 {
  class Activity: CoreStoreObject, AbstractEntity {
    
    typealias EntityType = Activity
    
    class var primaryKey: String {
      "category_id"
    }
    
    @Field.Stored("last_visit", dynamicInitialValue: { Date() })
    var last_visit: Date
    
    @Field.Stored("visits")
    var visits: Int64 = 0
    
    @Field.Stored("favourite")
    var favourite: Int = 0
    
    @Field.Stored("stream_id")
    var stream_id: Int64 = 0
    
    @Field.Relationship("stream")
    var stream: Stream?
    
    @Field.Relationship("epgs", inverse: \EPG.$activity)
    var epgs: Set<EPG>
    
    var id: Int {
      var hasher = Hasher()
      hasher.combine(self.stream_id)
      hasher.combine("\(self.stream_id).recent")
      return hasher.finalize()
    }
    
    class var orderBy: OrderBy<Activity> {
      OrderBy(
        .ascending("favourite"),
        .ascending("visits"),
        .descending("last_visit")
      )
    }
    
    static func getEPGIds() -> [String] {
      let now = Date()
      let stop = now.addingTimeInterval((60 * 60 * 25 * 2) * -1)
      guard
        let activites = Activity.find(
          Where<Activity>("(favourite > 0 OR visits > 0) AND last_visit > %s", stop),
          OrderBy<Activity>(
            .descending("last_visit"),
            .descending("visits")
          )
        ) as [Activity]?
      else {
        return []
      }
      let epgs = activites.filter { $0.stream?.epg_channel_id != nil }
      return epgs.map { $0.stream!.epg_channel_id }
    }
  }
}
