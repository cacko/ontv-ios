//
//  QuickStream.swift
//  QuickStream
//
//  Created by Alex on 11/10/2021.
//

import CoreStore
import Defaults
import Foundation

struct QuickStream: Validity {
  var idx: Int = 0
  
  var isValid: Bool {
    stream != nil
  }
  
  var stream: Stream?
  
  var icon: URL?
  
  init(
    idx: Int
  ) {
    self.idx = idx
  }
  
  init(
    idx: Int,
    stream: Stream
  ) {
    self.idx = idx
    self.stream = stream
    self.icon = stream.icon
  }
}

extension Provider.Stream {
  
  static let QuickStreams = QuickStreamsActor()
  
  actor QuickStreamsActor: ObservableObject {
    
    @MainActor @Published var streams: [QuickStream] = []
    
    @MainActor func load() {
      self.streams = Activity.find(
        Where<Activity>("favourite > 0"),
        OrderBy<Activity>(.ascending("favourite"))
      ).reduce(
        Array(repeating: QuickStream(idx: -1), count: 5)
          .enumerated().map {
            index,
            element in
            var ret = element
            ret.idx = index + 1
            return ret
          }
      ) { res, obj in
        let activity = obj
        var ret = res
        if let stream = activity.stream {
          ret[activity.favourite - 1] = QuickStream(
            idx: activity.favourite,
            stream: stream
          )
        }
        return ret
      }
      NotificationCenter.default.post(name: .updatebookmarks, object: nil)
    }
    
    @MainActor func bookmark(_ qs: QuickStream) async throws {
      guard let stream = Player.instance.stream else {
        throw PlayerError(id: .unexpected, msg: "kura")
      }
      let idx = qs.idx
      do {
        guard let activity = try await stream.addActivity() else {
          throw PlayerError(id: .unexpected, msg: "kura")
        }
        guard try await activity.addBookmark(idx) else {
          throw PlayerError(id: .unexpected, msg: "kura")
        }
        
        self.streams[idx - 1] = QuickStream(idx: idx, stream: stream)
        NotificationCenter.default.post(name: .updatebookmarks, object: nil)
        
      }
      catch let error {
        logger.error("\(error.localizedDescription)")
      }
      throw PlayerError(id: .unexpected, msg: "kura")
    }
  }
  
}

