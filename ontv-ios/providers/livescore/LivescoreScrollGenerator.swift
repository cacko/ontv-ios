//
//  LivescoreScrollGenerator.swift
//  ontv
//
//  Created by Alex on 17/11/2021.
//

import CoreStore
import Foundation

class LivescoreScrollGenerator: ScrollGeneratorProtocol {

  var items: [String]

  required init(
    _ list: ListPublisher<Livescore>
  ) {
    self.list = list
    self.items = list.snapshot.makeIterator()
      .filter { $0.$in_ticker! > 0 }
      .map { $0.$id! }
  }

  typealias EntityType = Livescore

  var list: ListPublisher<Livescore>

  var itemsSource: ArraySlice<String> = ArraySlice([])

  var isBackwards: Bool = true {
    didSet {
      itemsSource =
        ArraySlice(self.isBackwards ? self.items.reversed() : self.items)
    }
  }

  func update() {
    self.items = list.snapshot.makeIterator()
      .filter { $0.$in_ticker! > 0 }
      .map { $0.$id! }
    isBackwards = false
  }

  func next() -> String {
    guard items.count > 0 else {
      return ""
    }
    if itemsSource.count == 0 {
      isBackwards.toggle()
    }
    return itemsSource.popFirst()!
  }

}
