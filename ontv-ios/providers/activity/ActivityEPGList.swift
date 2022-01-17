//
//  EPGLiveList.swift
//  EPGLiveList
//
//  Created by Alex on 12/10/2021.
//

import CoreStore
import Foundation

class ActivityEPGList: ActivityStorageAbstract {

  override var order: OrderBy<Activity> {
    get {
      OrderBy<Activity>(
        .descending("favourite"),
        .descending("last_visit"),
        .descending("visits")
      )
    }
    set {}
  }

  override func update() {
    let now = Date()
    let isFavourite = 0
    let stop = now.addingTimeInterval(60 * 60 * 24 * 2 * -1)
    let predicates: [NSPredicate] = [
      NSPredicate(format: "favourite > %d", isFavourite as Int),
      NSPredicate(format: "last_visit > %@", stop as NSDate),
    ]
    query = Where<Activity>(NSCompoundPredicate(orPredicateWithSubpredicates: predicates))
    super.update()
  }

  override func fetch() {
    do {
      try list.refetch(
        From<Activity>()
          .where(query)
          .orderBy(order),
        sourceIdentifier: nil
      )
      state = API.State.ready
    }
    catch {
      logger.error("\(error.localizedDescription)")
    }
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
