//
//  EPGLiveList.swift
//  EPGLiveList
//
//  Created by Alex on 12/10/2021.
//

import CoreStore
import Foundation

extension Notification.Name {
  static let toggleEPGList = Notification.Name("toggle_epg_list")
}

class EPGLiveList: EPGStorageAbstract {
  
  override func update() {
    let now = Date()
    let stop = now.addingTimeInterval(60 * 60 * 5)
    let predicates: [NSPredicate] =
    [NSPredicate(format: "stop > %@ AND stop < %@", now as NSDate, stop as NSDate)]
    query = Where<EPG>(NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
    super.update()
  }
  
  override func postInit() {
    let center = NotificationCenter.default
    let mainQueue = OperationQueue.main
    
    center.addObserver(forName: .updaterecent, object: nil, queue: mainQueue) {
      _ in self.update()
    }
    super.postInit()
  }
  
  override func onChangeStream(stream: Stream) {
    self.update()
  }
}
