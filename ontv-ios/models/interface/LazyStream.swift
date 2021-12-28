//
//  LazyStream.swift
//  LazyStream
//
//  Created by Alex on 15/10/2021.
//

import CoreStore
import Foundation

protocol LazyStream {
  var stream_id: Int64 { get set }
  
  var category_id: Int64 { get set }
  
  var epg_channel_id: String { get set }
  
  var stream_icon: String { get set }
}

protocol LazyStreams {
  static var expiresIn: TimeInterval { get }
  
  var Streams: [LazyStream] { get }
  
  var title: String { get }
  
  var startTime: Date { get }
  
  var hasExpired: Bool { get }
}
