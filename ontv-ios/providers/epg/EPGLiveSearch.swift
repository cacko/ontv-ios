//
//  EPGLiveSearch.swift
//  EPGLiveSearch
//
//  Created by Alex on 12/10/2021.
//

import CoreStore
import Foundation

class EPGLiveSearch: EPGStorageAbstract {
  override var order: OrderBy<EPG> {
    get {
      OrderBy<EPG>([
        NSSortDescriptor(key: "start", ascending: true),
        NSSortDescriptor(
          key: "title",
          ascending: true,
          selector: #selector(NSString.localizedStandardCompare)
        ),
        NSSortDescriptor(key: "channel", ascending: true),
      ])
    }
    set {
    }
  }
  
  override func update() {
    if search.count < 3 {
      query = Where<EPG>("1=0")
    }
    else {
      let now = Date()
      let start = now.addingTimeInterval(60 * 60 * 3)
      let stop = now
      var predicates: [NSPredicate] = [
        NSPredicate(format: "start <= %@ AND stop => %@", start as NSDate, stop as NSDate)
      ]
      
      let terms = search.split(separator: " ")
      predicates += terms.map {
        NSPredicate(
          format: "(title CONTAINS[c] %@ OR desc CONTAINS[c] %@)",
          $0 as CVarArg,
          $0 as CVarArg
        )
      }
      
      query = Where<EPG>(NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
    }
    super.update()
  }
}
