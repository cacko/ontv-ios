//
//  Background.swift
//  Background
//
//  Created by Alex on 14/10/2021.
//

import Foundation
import SwiftUI

extension Theme.Color {
  enum Background {
    static let header = LinearGradient(
      colors: [
        Color.black.opacity(0.8), Color.blue.opacity(0.9), Color.red.opacity(0.9),
        Color.gray.opacity(0.9),
      ],
      startPoint: UnitPoint.leading,
      endPoint: UnitPoint.trailing
    )
    static let metadata = Color(.black).opacity(0.5)
    static let headerTitle = Color(.black).opacity(0.4)
    static let ticker = Color(.black).opacity(0.4)
    static let controls = Color(.black).opacity(0.6)
  }
  enum Hover {
    enum listItem {
      static let on = Color(.white).opacity(0.2)
      static let off = Color(.clear)
    }
  }
  
  enum State {
    static let live = Color(.red).opacity(0.5)
    static let off = Color(.clear)
    static let ticker = LinearGradient(
      colors: [
        Color.black.opacity(0.5), Color.blue.opacity(0.5), Color.yellow.opacity(0.5),
        Color.gray.opacity(0.5),
      ],
      startPoint: UnitPoint.leading,
      endPoint: UnitPoint.trailing
    )
  }
  
  enum Icon {
    static let disabled = Color(.white).opacity(0.5)
    static let enabled = Color(.white).opacity(0.8)
  }
  
}
