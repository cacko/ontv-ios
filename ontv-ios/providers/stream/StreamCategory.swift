//
//  StreamCategory.swift
//  craptv
//
//  Created by Alex on 29/10/2021.
//

import CoreStore
import Foundation

extension StreamStorage {
  class Category: Search {
    override func update() {
      self.query = Where<Stream>(NSPredicate(format: "category_id = %@", search))
      self.fetch()
//      self.onChangeStream(stream: Player.instance.stream)
    }
    
    override init() {
      super.init()
    }
    
    override func onNavigate(_ notification: Notification) {}
    
    override func selectNext() throws {
      guard let res = try self.getResultOffset(off: .down) as ObjectPublisher<Stream>? else {
        return
      }
      self.selected = res
      self.selectedId = res.id!
    }
    
    override func selectPrevious() throws {
      guard let res = try self.getResultOffset(off: .up) as ObjectPublisher<Stream>? else {
        return
      }
      self.selected = res
      self.selectedId = res.id!
    }
    
    func getResultOffset(off: ListNavigation) throws -> ObjectPublisher<Stream> {
      guard list.snapshot.count > 0 else {
        throw Provider.Error(id: .outOfBounds, msg: "u levo")
      }
      let idx = self.getSelectIdx()
      var newIdx = idx
      switch off {
      case .up:
        newIdx = list.snapshot.index(before: idx)
      case .down:
        newIdx = list.snapshot.index(after: idx)
      case .select:
        NotificationCenter.default.post(name: .selectStream, object: self.selected.object)
      default:
        throw Provider.Error(id: .outOfBounds, msg: "kura ti tzanko")
      }
      
      guard list.snapshot.indices.contains(newIdx) else {
        throw Provider.Error(id: .outOfBounds, msg: "kura ti tzanko")
      }
      
      return list.snapshot[newIdx]
    }
    
    func getSelectIdx() -> ListSnapshot<Stream>.Index {
      
      guard let _selected = self.selected as ObjectPublisher<Stream>? else {
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
    
  }
}
