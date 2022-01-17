//
//  EPGGuide.swift
//  EPGGuide
//
//  Created by Alex on 12/10/2021.
//

import CoreStore
import Foundation

class EPGGuide: EPGStorageAbstract {
  override func update() {
    guard search.count > 0 else {
      self.state = .notavail
      return
    }
    
    let now = Date()
    let predicates: [NSPredicate] = [
      NSPredicate(format: "stop > %@", now as NSDate),
      NSPredicate(format: "channel = %@", search),
    ]
    self.query = Where<EPG>(NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
    super.update()
  }
  
  override func onChangeStream(stream: Stream) {
    DispatchQueue.main.async {
      if stream.epg_channel_id.count == 0 {
        self.state = .notavail
      }
      else {
        self.state = .loading
        self.search = stream.epg_channel_id
        self.state = .ready
      }
    }
  }
}
