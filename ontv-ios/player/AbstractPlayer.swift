//
//  AbstractPlayer.swift
//  craptv
//
//  Created by Alex on 23/10/2021.
//

import Defaults
import Foundation
import SwiftUI

class AbstractPlayer: NSObject, PlayerVendorProtocol {
  class var vendor: VendorInfo {
    get { VendorInfo(icon: "", hint: "", id: .unknown, features: []) }
    set {}
  }

  typealias PlayerType = AbstractPlayer

  var volume: Float {
    get { fatalError() }
    set { fatalError() }
  }

  var isMuted: Bool {
    get { fatalError() }
    set { fatalError() }
  }

  required init(
    _ controller: Player
  ) {
    super.init()
  }

  func initView(_ view: VideoView) {
    fatalError("Not implemented")
  }

  func deInitView() {
    fatalError()
  }

  func sizeView(_ newSize: CGSize) {

  }

  func play(_ stream: Stream) {
    fatalError("Not implemented")
  }

  func stop() {
    fatalError("Not implemented")
  }

}
