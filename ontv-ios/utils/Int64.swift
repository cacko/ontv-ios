//
//  Int64.swift
//  ontv
//
//  Created by Alex on 22/11/2021.
//

import Foundation
import CommonCrypto

extension Int64 {
  func isEqual(_ other: Int) -> Bool {
    self.toNative() == other.int64
  }
  
  var string: String {
    String(format: "%d", self.toNative())
  }
  
  var int: Int {
    Int(truncatingIfNeeded: self.toNative())
  }
  
  var sha1: String {
    let hs = String(self.toNative())
    let data = Data(hs.utf8)
    var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
    data.withUnsafeBytes {
      _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
    }
    let hexBytes = digest.map { String(format: "%02hhx", $0) }
    return hexBytes.joined()
  }
}
