//
//  PlayerProtocol.swift
//  craptv
//
//  Created by Alex on 02/11/2021.
//

import Defaults
import Foundation
import SwiftUI

enum Sorting {
  case ascending, descending
}

enum PlayerState {
  case opening, playing, stopped, error, retry, buffering, none, paused
}

enum MetadataState {
  case loading, loaded
}

enum VendorFeature {
  case volume
}

struct PlayerError: Error, Identifiable, Equatable {
  var id: Errors
  
  enum Errors {
    case deviceLoad
    case accessDenied
    case unexpected
    case trackFailed
    case retrying
    case null
  }
  
  //    let kind: Errors
  let msg: String
}

enum StreamInfo {
  struct Video {
    var codec: String = "Unknown"
    var resolution: CGSize = CGSize(width: 0, height: 0)
  }
  struct Audio {
    var codec: String = "Unknown"
    var channels: Int = 0
    var rate: Int = 0
  }
  struct Metadata {
    var video: Video
    var audio: Audio
  }
}


protocol PlayerVendorProtocol {
  var volume: Float { get set }
  var isMuted: Bool { get set }
  static var vendor: VendorInfo { get set }
  init(_ controller: Player)
  func play(_ stream: Stream)
  func stop()
  func pause()
  func resume()
  func initView(_ view: VideoView)
  func sizeView(_ newSize: CGSize)
  func deInitView()
}


extension Notification.Name {
  static let vendorChange = Notification.Name("renderer_switch")
  static let vendorChanged = Notification.Name("vendor_changed")
  static let vendorToggle = Notification.Name("vendor_toggle")
}

enum PlayVendor: Int, DefaultsSerializable {
  case avfoundation = 1
  case unknown = 0
  case ffmpeg = 3
}

struct VendorInfo {
  let icon: String
  let hint: String
  let id: PlayVendor
  let features: [VendorFeature]
}

enum PlayerControlsState {
  case hidden, visible, hovered, always
}

enum PlayerControlsPosition {
  case top, bottom, center
}


protocol PlayerProtocol: ObservableObject {
  var error: PlayerError { get set }
  var state: PlayerState { get set }
  var onTop: Bool { get set }
  var isFullscreen: Bool { get set }
  var display: Bool { get set }
  var opacity: Double { get set }
  var size: CGSize { get set }
  var iconSize: CGSize { get set }
  var stream: Stream! { get set }
  var isMuted: Bool { get set }
  var epgId: String { get set }
  var category: Category? { get set }
  var contentToggle: ContentToggle? { get set }
  var volume: Float { get set }
  var controlsState: PlayerControlsState { get set }
  var controlsPosition: PlayerControlsPosition { get set }
  var icon: String { get set }
  var hint: String { get set }
  var metadata: StreamInfo.Metadata { get set }
  var vendor: VendorInfo! { get set }
  var availableVendors: [VendorInfo] { get set }
  
  func initView(_ view: VideoView)
  func play(_ stream: Stream)
  func retry()
  func stop()
  func pause()
  func resume()
  func prev() async
  func next() async
  func onStartPlaying()
  func onStopPlaying()
  func onAudioCommand(_ parameter: Audio.Parameter)
}
