//
//  StreamActivity.swift
//  craptv
//
//  Created by Alex on 20/10/2021.
//

import CoreStore
import Foundation

extension Stream {
  
  func addActivity() async throws -> Activity? {
    try Stream.dataStack.perform(
      synchronous: { (transaction) -> Activity? in
        guard let stream = transaction.fetchExisting(self) else {
          return nil
        }
        
        guard !stream.isAdult else {
          
          return nil
        }
        
        guard stream.activity == nil else {
          return stream.activity
        }
        
        stream.activity = transaction.create(Into<Activity>())
        return stream.activity
      })
  }
}
