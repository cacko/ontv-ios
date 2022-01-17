//
//  StreamSearch.swift
//  craptv
//
//  Created by Alex on 29/10/2021.
//

import CoreStore
import Foundation

extension StreamStorage {

  class Search: NSObject, ObservableObject, StorageProvider {

    @Published var active: Bool = false

    @Published var state: API.State = .notavail

    typealias EntityType = Stream

    var selectedId: String = "" {
      didSet {
        objectWillChange.send()
      }
    }

    @Published var search: String = "" {
      didSet {
        self.update()
      }
    }

    var query: Where<Stream> = Where<Stream>(NSPredicate(value: false))

    var order: OrderBy<Stream> = Stream.orderBy

    var list: ListPublisher<Stream> {
      didSet {
        objectWillChange.send()
      }
    }

    var selected: ObjectPublisher<Stream>! {
      didSet {
        objectWillChange.send()
      }
    }

    override init() {
      self.list = Self.dataStack.publishList(
        From<Stream>()
          .where(self.query)
          .orderBy(self.order)
      )
      super.init()
      self.observe()
      guard let stream = Player.instance.stream as Stream? else {
        return
      }
      self.onChangeStream(stream: stream)
    }

    func update() {
      guard search.count > 2 else {
        self.state = .notavail
        return
      }

      let terms = search.split(separator: " ")
      self.query = Where<Stream>(
        NSCompoundPredicate(
          type: .and,
          subpredicates: terms.map { NSPredicate(format: "name CONTAINS[c] %@", $0 as CVarArg) }
        )
      )
      DispatchQueue.main.async {
        self.state = .loading
        do {
          try self.list.refetch(
            From<Stream>()
              .where(self.query)
              .orderBy(self.order),
            sourceIdentifier: nil
          )
        }
        catch {
          logger.error("\(error.localizedDescription)")
        }
        self.state = .ready
      }
    }
    

    func onNavigate(_ notification: Notification) {
      logger.error("kira mi janko")
    }

    func selectNext() throws {
      logger.error("kira mi janko")

    }

    func selectPrevious() throws {
      logger.error("kira mi janko")
    }
  }
}
