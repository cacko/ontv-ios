//
//  EPGStorage.swift
//  EPGStorage
//
//  Created by Alex on 12/10/2021.
//

import Combine
import CoreStore
import Foundation
import SwiftUI

enum EPGListToggleType {
  case state
}

enum EPGStorage {

  static let epglist = EPGLiveList()
  static let search = EPGLiveSearch()
  static let guide = EPGGuide()

  private static var _active: ContentToggle = .none

  static var active: ContentToggle {
    get {
      Self._active
    }
    set {
      Self._active = Self._active == newValue ? .none : newValue
      Player.instance.contentToggle = self._active
    }
  }

}

class EPGStorageAbstract: NSObject, ObservableObject, StorageProvider {

  @Published var active: Bool = false
  @Published var state: API.State = .notavail
  @Published var selectedId: String = ""

  typealias EntityType = EPG

  var query = Where<EPG>(NSPredicate(value: false))

  var order = OrderBy<EPG>(
    .ascending("channel"),
    .ascending("start"),
    .ascending("title")
  )

  @Published var search: String = "" {
    didSet {
      self.update()
    }
  }

  var list: ListPublisher<EPG> {
    didSet {
      objectWillChange.send()
    }
  }

  var selected: ObjectPublisher<EPG>! {
    didSet {
      objectWillChange.send()
    }
  }

  let dataStack = CoreStoreDefaults.dataStack
  let player = Player.instance
  var cancellables = Set<AnyCancellable>()

  override init() {
    self.list = self.dataStack.publishList(
      From<EPG>()
        .sectionBy("channel")
        .where(self.query)
        .orderBy(self.order)
    )
    super.init()
    self.postInit()
  }

  func postInit() {
    let center = NotificationCenter.default
    let mainQueue = OperationQueue.main

    center.addObserver(forName: .changeStream, object: nil, queue: mainQueue) { note in
      if let stream = note.object as? Stream {
        self.onChangeStream(stream: stream)
      }
    }

    center.addObserver(forName: .updateepg, object: nil, queue: mainQueue) { _ in
      self.update()
    }

    //    center.addObserver(forName: .search_navigate, object: nil, queue: mainQueue) {
    //      note in
    //
    //      guard let action = note.object as? AppNavigation else {
    //        return
    //      }
    //
    //      do {
    //        switch action {
    //        case .next:
    //          try self.selectNext()
    //        case .previous:
    //          try self.selectPrevious()
    //        case .select:
    //          guard self.selected != nil else {
    //            return
    //          }
    //          NotificationCenter.default.post(name: .selectStream, object: self.selected.stream!)
    //        }
    //      }
    //      catch let error {
    //        logger.error("\(error.localizedDescription)")
    //      }
    //    }
    self.update()
  }

  func onChangeStream(stream: Stream) {

  }

  func fetch() {
    Task.init {
      DispatchQueue.main.async {
        self.state = .loading
      }
      if EPG.needsUpdate {
        try await API.Adapter.updateEPG()
      }
      DispatchQueue.main.async {
        do {
          try self.list.refetch(
            From<EPG>()
              .sectionBy("channel")
              .where(self.query)
              .orderBy(self.order),
            sourceIdentifier: nil
          )
          self.state = .ready
        }
        catch {
          logger.error(">> epg search error \(error.localizedDescription)")
        }
      }
    }
  }

  func update() {
    self.fetch()
  }

  func selectNext() throws {
    guard let res = try self.getResultOffset(off: .next) as ObjectPublisher<EPG>? else {
      return
    }
    self.selected = res
    self.selectedId = res.id!
  }

  func selectPrevious() throws {
    guard let res = try self.getResultOffset(off: .previous) as ObjectPublisher<EPG>? else {
      return
    }
    self.selected = res
    self.selectedId = res.$id!
  }

  func getResultOffset(off: AppNavigation) throws -> ObjectPublisher<EPG> {
    guard list.snapshot.count > 0 else {
      throw Provider.Error(id: .outOfBounds, msg: "u levo")
    }
    let idx = self.getSelectIdx()
    var newIdx = idx
    switch off {
    case .previous:
      newIdx = list.snapshot.index(before: idx)
    case .next:
      newIdx = list.snapshot.index(after: idx)
    case .select:
      throw Provider.Error(id: .outOfBounds, msg: "kura ti tzanko")
    }

    guard list.snapshot.indices.contains(newIdx) else {
      throw Provider.Error(id: .outOfBounds, msg: "kura ti tzanko")
    }

    return list.snapshot[newIdx]
  }

  func getSelectIdx() -> ListSnapshot<EPG>.Index {

    guard let _selected = self.selected as ObjectPublisher<EPG>? else {
      return -1
    }

    guard self.list.snapshot.contains(_selected) else {
      return -1
    }

    guard let result = self.list.snapshot.firstIndex(of: self.selected) else {
      return -1
    }

    return result
  }

  func onNavigate(_ notitication: Notification) {

  }

}
