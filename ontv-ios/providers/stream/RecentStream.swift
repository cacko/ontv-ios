//
//  RecentStream.swift
//  RecentStream
//
//  Created by Alex on 12/10/2021.
//

import CoreStore
import Defaults
import Foundation
import MapKit

extension Notification.Name {
  static let refreshrecents = Notification.Name("refresh_recents")
}

struct RecentStreamError: Error, Identifiable, Equatable {
  var id: Errors

  enum Errors {
    case limitReached
  }

  let msg: String
}

extension Provider.Stream {

  static let RecentItems = RecentStreams()

  static let Recent = RecentActor()

  class RecentStreams: NSObject, ObservableObject {

    @Published var streams: [Stream] = []
    @Published var canGoBack: Bool = false {
      didSet {
        objectWillChange.send()
      }
    }
    @Published var canGoForward: Bool = false {
      didSet {
        objectWillChange.send()
      }
    }
    @Published var currentPosition: Int = 0 {
      didSet {
        DispatchQueue.main.async {
          self.canGoBack = self.streams.count - self.currentPosition > 0
          self.canGoForward = self.currentPosition > 0
        }
      }
    }

    override init() {

      super.init()

      let center = NotificationCenter.default
      let mainQueue = OperationQueue.main

      center.addObserver(forName: .refreshrecents, object: nil, queue: mainQueue) { _ in
        self.load()
      }

      self.load()
    }

    func load() {
      Task.init {
        self.streams = await Recent.streams
      }
    }
  }

  actor RecentActor {
    var autoPlay: Stream? = nil

    var player = Player.instance

    var streams: [Stream] = []

    func add(_ obj: Stream) async throws {

      guard let activity = try await obj.addActivity() else {
        throw PlayerError(id: .unexpected, msg: "kiura ti acticity")
      }
      Activity.dataStack.perform(
        asynchronous: { (transaction) -> Void in
          guard let act = transaction.edit(activity) else {
            throw PlayerError(id: .unexpected, msg: "kuira ti act")
          }
          guard let actStream = act.stream else {
            throw PlayerError(id: .unexpected, msg: "kura mi actystream")
          }

          guard !actStream.isAdult else {
            throw PlayerError(id: .unexpected, msg: "pron")
          }

          act.stream_id = actStream.stream_id

          Task.init {
            try await activity.addEPG()
            guard !self.streams.contains(obj) else {
              throw PlayerError(id: .unexpected, msg: "mamati")
            }
            self.streams.insert(obj, at: 0)
            self.streams.removeLast()
            RecentItems.currentPosition += 1
            NotificationCenter.default.post(
              name: .refreshrecents,
              object: nil
            )
          }
        },
        completion: { _ in return }
      )
    }

    func register() {
      let center = NotificationCenter.default
      let mainQueue = OperationQueue.main
      center.addObserver(forName: .recent, object: nil, queue: mainQueue) { note in
        guard let navigation = note.object as? AppNavigation else {
          return
        }
        self.onNavigation(navigation)
      }
    }

    func load() {
      self.streams = Activity.find(
        OrderBy<Activity>(.descending("last_visit"))
      ).reduce([]) {
        (res, obj) in

        guard let activity: Activity = obj as Activity? else {
          return res
        }

        guard let stream: Stream = activity.stream else {
          return res
        }

        guard !stream.isAdult else {
          return res
        }

        return res + [stream]
      }
      self.autoPlay = self.streams.first

    }

    private func onNavigation(_ navigation: AppNavigation) {
      guard let stream = self.player.stream else {
        return
      }
      guard var pos = self.streams.firstIndex(of: stream) else {
        return self.player.play(stream)
      }

      switch navigation {
      case .next:
        pos = self.streams.index(after: pos)
        RecentItems.currentPosition += 1
      case .previous:
        pos = self.streams.index(before: pos)
        RecentItems.currentPosition -= 1
      default:
        return
      }

      guard self.streams.indices.contains(pos) else {
        return
      }

      self.player.play(self.streams[pos])
    }
  }
}
