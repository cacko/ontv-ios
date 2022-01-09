//
//  Schema.swift
//  Schema
//
//  Created by Alex on 13/10/2021.
//

import CoreStore
import Foundation

typealias EPG = V1.EPG
typealias Stream = V1.Stream
typealias Category = V1.Category
typealias Schedule = V1.Schedule
typealias Activity = V1.Activity
typealias Livescore = V1.Livescore
typealias League = V1.League

enum V1 {
}

class Schema {
  class func addStorageAndWait() {
    do {
      CoreStoreDefaults.dataStack = DataStack(
        CoreStoreSchema(
          modelVersion: "V1",
          entities: [
            Entity<V1.Stream>("Stream"),
            Entity<V1.Category>("Category"),
            Entity<V1.Schedule>("Schedule"),
            Entity<V1.EPG>("EPG"),
            Entity<V1.Activity>("Activity"),
            Entity<V1.Livescore>("Livescore"),
            Entity<V1.League>("League"),
          ]
        )
      )
      try CoreStoreDefaults.dataStack.addStorageAndWait()
    }
    catch {
      logger.error("\(error.localizedDescription)")
    }
  }
}
