//
//  Date.swift
//  Date
//
//  Created by Alex on 03/10/2021.
//

import Foundation

extension Date {
  
  func isSameDay(_ date2: Date) -> Bool {
    let diff = Calendar.current.dateComponents([.day], from: self, to: date2)
    if diff.day == 0 {
      return true
    }
    else {
      return false
    }
  }
  
  var HHMM: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: self)
  }
}
