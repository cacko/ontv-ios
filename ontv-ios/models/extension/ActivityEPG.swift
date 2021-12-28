//
//  ActivityEPG.swift
//  craptv
//
//  Created by Alex on 20/10/2021.
//

import CoreStore
import Foundation

extension Activity {
  
  func addBookmark(_ idx: Int) async throws -> Bool {
    try Activity.dataStack.perform(
      synchronous: {
        (transaction) -> Bool in
        
        guard let activity = self.asEditable(in: transaction) else {
          return false
        }
        
        guard let activityStream = activity.stream else {
          return false
        }
        
        activity.last_visit = Date()
        activity.favourite = idx
        activity.visits += 1
        activity.stream_id = activityStream.stream_id
        activity.epgs = Set(
          try transaction.fetchAll(
            From<EPG>(),
            Where<EPG>("channel = %s", activity.stream?.epg_channel_id as Any),
            OrderBy<EPG>(.ascending("start"))
          ))
        return true
      }
    )
  }
  
  func addEPG() async throws {
    try Activity.dataStack.perform(
      synchronous: { (transaction) -> Void in
        
        guard let actiity = transaction.fetchExisting(self) else {
          return
        }
        
        guard let stream = actiity.stream else {
          return
        }
        
        actiity.visits += 1
        actiity.last_visit = Date()
        
        let predicates: [NSPredicate] = [
          NSPredicate(format: "stop > %@", Date() as NSDate),
          NSPredicate(format: "channel = %@", stream.epg_channel_id),
        ]
        let query = Where<EPG>(
          NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
        let order = OrderBy<EPG>(
          .ascending("stop")
        )
        
        let epgs = try transaction.fetchAll(
          From<EPG>()
            .where(query).orderBy(order)
        )
        
        actiity.epgs = Set(epgs)
      }
    )
  }
  
}
