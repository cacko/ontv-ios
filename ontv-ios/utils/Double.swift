//
//  Double.swift
//  ontv
//
//  Created by Alex on 22/11/2021.
//

import Foundation

extension Double {
  
  var string: String {
    String(format: "%f", self.toNative())
  }
}
