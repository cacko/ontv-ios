//
//  ScrollGenerator.swift
//  ontv
//
//  Created by Alex on 17/11/2021.
//

import CoreStore
import Foundation

protocol ScrollGeneratorProtocol {
  associatedtype EntityType: CoreStoreObject
  var items: [String] { get set }
  var itemsSource: ArraySlice<String> { get set }
  var isBackwards: Bool { get set }
  var count: Int { get }
  var list: ListPublisher<EntityType> { get set }
  init(_ list: ListPublisher<EntityType>)
  func next() -> String
}

extension ScrollGeneratorProtocol {
  var count: Int {
    self.items.count
  }
}
