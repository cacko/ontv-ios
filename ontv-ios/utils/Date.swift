//
//  Date.swift
//  Date
//
//  Created by Alex on 03/10/2021.
//

import Foundation
import SwiftDate

extension Date {

  var isToday: Bool {
    let diff = Calendar.current.dateComponents([.day], from: self, to: Date())
    return diff.day == 0
  }

  func isCloseTo(precision: TimeInterval = 300) -> Bool {
    return Date().compareCloseTo(self, precision: precision)
  }

  var HHMM: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: self)
  }
}
