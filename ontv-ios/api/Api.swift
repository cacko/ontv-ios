//
//  Api.swift
//  Api
//
//  Created by Alex on 27/09/2021.
//

import Combine
import CoreStore
import Defaults
import Foundation
import ObjectiveC
import SwiftUI

extension Defaults.Keys {
  static let userinfo = Key<API.UserInfo>("userinfo", default: .init(username: "", password: ""))
  static let serverinfo = Key<API.ServerInfo>(
    "serverinfo",
    default: .init(url: "", port: "", server_protocol: "")
  )
}

enum API {

  enum UpdateOperation {
    case done, notify, state
  }

  struct Update {
    var operation: UpdateOperation
    var target: FetchType?
    var notification: Notification.Name?
    var destination: StateDestination?
    var value: Any?
  }

  class Updater: NSObject {

    let publisher = PassthroughSubject<Update, Never>()

    private var queue: [API.FetchType] = []

    private var current: API.FetchType!

    func add(task: API.FetchType) {
      self.queue.insert(task, at: 0)
      guard current == nil else {
        return
      }
      current = self.queue.popLast()
      API.Adapter.fetch(task)
    }

    func done(task: API.FetchType) {
      publisher.send(Update(operation: .done, target: task))
      switch task {
        
      case .streams:
        self.state(destination: .streams, value: .ready)
      case .schedule:
        self.state(destination: .schedule, value: .ready)
      case .epg:
        self.state(destination: .epg, value: .ready)
      case .livescore:
        self.state(destination: .livescore, value: .ready)
      case .idle:
        break
      case .leagues:
        self.state(destination: .leagues, value: .ready)
      case .user:
        self.state(destination: .api, value: .ready)
      }
      
      guard queue.count > 0 else {
        return
      }
      current = self.queue.popLast()
      API.Adapter.fetch(current)
    }

    func notify(name: Notification.Name, value: Any? = nil) {
      publisher.send(Update(operation: .notify, notification: name, value: value as Any))
    }

    func state(destination: StateDestination, value: API.State) {
      publisher.send(Update(operation: .state, destination: destination, value: value as Any))
    }

    func syncState(value: API.State) {

    }

  }

  enum StateDestination {
    case streams, schedule, epg, livescore, idle, leagues, user, api, inprogress, loggedin
  }

  enum State {
    case loading, ready, error, loggedin, idle, boot, notavail
  }

  enum FetchType {
    case streams, schedule, epg, livescore, idle, leagues, user
  }

  enum LoadingItem: String, DefaultsSerializable {
    case epg = "Loading EPG"
    case schedule = "Loading TheSportsDb"
    case stream = "Loading streams"
    case category = "Loading categories"
    case loaded = "Done"
    case livescore = "Loading livescores"
    case leagues = "Loading leagues"
  }

  static let Adapter = ApiAdapter()

  class ApiAdapter: NSObject, ObservableObject {
    @Published var error: API.Exception? = nil
    @Published var loading: API.LoadingItem = .loaded
    @Published var epgState: API.State = .boot
    @Published var user: UserInfo? = nil
    @Published var expires: String = ""
    @Published var livescoreState: API.State = .idle
    @Published var scheduleState: API.State = .idle
    @Published var streamsState: API.State = .idle
    @Published var leaguesState: API.State = .idle
    @Published var fetchType: API.FetchType = .idle
    @Published var state: API.State = .boot
    @Published var inProgress: Bool = false
    @Published var progressTotal: Double = 0
    @Published var progressValue: Double = 0
    @Published var loggedIn: Bool = false

    var server_info: ServerInfo = ServerInfo(
      url: Defaults[.server_host],
      port: Defaults[.server_port],
      https_port: Defaults[.server_secure_port],
      server_protocol: Defaults[.server_protocol],
      rtmp_port: "",
      timezone: "",
      timestamp_now: 0,
      time_now: ""
    )

    var username: String = Defaults[.username]

    var password: String = Defaults[.password]

    private var cancellable: Cancellable!
    private let updater: Updater = Updater()

    func login(username: String, password: String) async {
      self.username = username
      self.password = password
      await login()
    }

    func clean() {
      //      guard tasks.count > 0 else {
      //        return
      //      }
      //      tasks.forEach { $0.cancel() }
    }

    func fetch(_ type: API.FetchType) {
      Task.init {
        switch type {
        case .user:
          try await self.updateUser()
          break
        case .streams:
          try await self.updateStreams()
          break
        case .epg:
          try await self.updateEPG()
          break
        case .schedule:
          try await self.updateSchedule()
          break
        case .livescore:
          try await self.updateLivescore()
          break
        case .leagues:
          try await self.updateLeagues()
          break
        case .idle:
          self.fetchType = .idle
        }
      }
    }

    func login() async {
      if username.count == 0 || password.count == 0 {
        DispatchQueue.main.async {
          self.state = .error
          self.error = API.Exception.invalidLogin("new app")
          Defaults[.account_status] = "Not connected"
          NotificationCenter.default.post(name: .contentToggle, object: ContentToggle.settings)
        }
        return
      }

      cancellable = updater.publisher
        .sink { value in
          DispatchQueue.main.async {
            switch value.operation {
            case .done:
              break
            case .notify:
              NotificationCenter.default.post(name: value.notification!, object: value.value)
            case .state:
              switch value.destination {
              case .streams:
                self.streamsState = value.value as! API.State
              case .schedule:
                self.scheduleState = value.value as! API.State
              case .epg:
                self.epgState = value.value as! API.State
              case .livescore:
                self.livescoreState = value.value as! API.State
              case .idle:
                break
              case .leagues:
                self.leaguesState = value.value as! API.State
              case .user:
                self.state = value.value as! API.State
              case .api:
                self.state = value.value as! API.State
              case .inprogress:
                self.inProgress = value.value as! API.State == .loading
              case .none:
                break
              case .loggedin:
                self.loggedIn = value.value as! API.State == .loggedin
              }
            }
            print("update sink \(value)")
          }

        }

      do {
//        DispatchQueue.main.async {
//          self.state = .loading
//        }

        updater.add(task: .user)

        if Stream.isLoaded {
          updater.state(destination: .streams, value: .ready)
        }
        else {
          updater.state(destination: .inprogress, value: .loading)
        }

        updater.add(task: .leagues)
        updater.add(task: .streams)
        updater.add(task: .schedule)
        updater.add(task: .epg)
      }
    }

    func updateUser() async throws {
      do {
        let response: LoginResponse =
          try await fetchCodable(url: Endpoint.Login, codable: LoginResponse.self)
          as! API.LoginResponse

        DispatchQueue.main.async {
          self.user = response.user_info
          self.server_info = response.server_info
          Defaults[.userinfo] = response.user_info
          Defaults[.serverinfo] = response.server_info
          if let exp_date = self.user?.exp_date {
            let dt = Date(timeIntervalSince1970: TimeInterval(Int64(exp_date)!))
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            self.expires = formatter.localizedString(for: dt, relativeTo: Date())
            Defaults[.account_status] = "Connected. \(self.expires) left"
            if self.user!.isSubscriptionExpired() {
              self.updater.state(destination: .api, value: .error)
              self.error = API.Exception.subscriptionExpired(self.expires)
              self.updater.done(task: .user)
              return
            }
          }
          self.updater.done(task: .user)
          self.updater.notify(name: .loggedin)
          self.updater.state(destination: .loggedin, value: .loggedin)
          self.updater.state(destination: .api, value: .loggedin)
        }
      }
      catch let error {
        guard let storedUser = Defaults[.userinfo] as UserInfo? else {
          throw error
        }
        guard let storedServer = Defaults[.serverinfo] as ServerInfo? else {
          throw error
        }

        guard storedUser.username != "" && storedServer.url != "" else {
          Defaults[.account_status] = "Not connected"
          throw error
        }

        DispatchQueue.main.async {
          self.user = storedUser
          self.server_info = storedServer
          if let exp_date = self.user?.exp_date {
            let dt = Date(timeIntervalSince1970: TimeInterval(Int64(exp_date)!))
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            self.expires = formatter.localizedString(for: dt, relativeTo: Date())
            if storedUser.isSubscriptionExpired() {
              self.state = .error
              self.error = API.Exception.subscriptionExpired(self.expires)
              return
            }
          }
          self.updater.done(task: .user)
          self.updater.state(destination: .loggedin, value: .loggedin)
          self.updater.state(destination: .api, value: .loggedin)
          self.updater.notify(name: .loggedin)
        }
      }
    }

    func updateSchedule() async throws {
      guard self.scheduleState != .loading else {
        return
      }

      guard Schedule.needsUpdate else {
        updater.notify(name: .updateschedule)
        self.updater.done(task: .schedule)
        return
      }

      updater.state(destination: .schedule, value: .loading)
      
      try await Schedule.fetch(url: Endpoint.Schedule) { _ in
        Task.init {
          do {
            try await Schedule.delete(Schedule.clearQuery)
            Defaults[.scheduleUpdated] = Date()
            self.updater.done(task: .schedule)
            self.updater.notify(name: .updateschedule)
          }
          catch let error {
            self.updater.done(task: .schedule)
            logger.error("\(error.localizedDescription)")
          }
        }
      }
    }

    func updateStreams() async throws {
      guard self.streamsState != .loading else {
        return
      }

      guard Stream.needsUpdate else {
        self.updater.done(task: .streams)
        self.updater.notify(name: .loaded)
        return
      }

      self.updater.state(destination: .streams, value: .loading)
      
      try await Category.fetch(url: Endpoint.Categories) { _ in
        Task.init {
          do {
            try await Category.delete(Category.clearQuery)
            try await Stream.fetch(url: Endpoint.Streams) { _ in
              Task.init {
                do {
                  try await Stream.delete(Stream.clearQuery)
                  self.updater.notify(name: .updatestreams)
                  self.updater.state(destination: .inprogress, value: .ready)
                  self.updater.done(task: .streams)
                  self.updater.notify(name: .loaded)

                    Defaults[.streamsUpdated] = Date()
                }
                catch let error {
                  self.updater.done(task: .streams)
                  self.updater.notify(name: .loaded)
                  logger.error(">>> \(error.localizedDescription)")
                }
              }
            }
          }
          catch let error {
            logger.error("??? \(error.localizedDescription)")
          }
        }
      }
    }

    func updateEPG() async throws {
      guard self.epgState != .loading else {
        return
      }

      guard EPG.needsUpdate else {
        updater.state(destination: .epg, value: .ready)
        updater.notify(name: .updateepg)
        self.updater.done(task: .epg)

        return
      }

      updater.state(destination: .epg, value: .loading)

      try await EPG.fetch(url: Endpoint.EPG) { _ in
        Task.detached {
          do {
            try await EPG.delete(EPG.clearQuery)
            Defaults[.epgUpdated] = Date()
              self.updater.done(task: .epg)
            self.updater.notify(name: .updateepg)
          }
          catch let error {
              self.updater.done(task: .epg)
            logger.error("\(error.localizedDescription)")
          }
        }
      }
    }

    func updateLivescore() async throws {
      Task.detached {
        guard self.livescoreState != .loading else {
          return
        }
        DispatchQueue.main.async {
          self.fetchType = .livescore
          self.livescoreState = .loading
        }

        try await Livescore.fetch(url: Endpoint.Livescores) { _ in
          Task.detached {
            do {
              try await Livescore.delete(Livescore.clearQuery)
              DispatchQueue.main.async {
                self.livescoreState = .ready
                self.fetchType = .idle
              }
            }
            catch let error {
              logger.error("\(error.localizedDescription)")
              try await Livescore.delete(Livescore.clearQuery)
              DispatchQueue.main.async {
                self.livescoreState = .ready
                self.fetchType = .idle
              }
            }
          }
        }
        return
      }
    }

    func updateLeagues() async throws {
      guard self.leaguesState != .loading else {
        return
      }

      guard League.needsUpdate else {
        self.updater.done(task: .leagues)
        return
      }

      DispatchQueue.main.async {
        self.loading = .leagues
        self.leaguesState = .loading
        self.fetchType = .leagues
      }

      try await League.fetch(url: Endpoint.Leagues) { _ in
        Defaults[.leaguesUpdated] = Date()
        self.updater.done(task: .leagues)
        self.updater.notify(name: .leagues_updates)
      }
    }

    func fetchData(
      url: URL
    ) async throws -> [[String: Any]] {
      let (json, response) = try await URLSession.shared.data(from: url)
      if response.mimeType != "application/json" {
        throw API.Exception.notJson
      }
      let data =
        try
        (JSONSerialization.jsonObject(with: json, options: [.mutableContainers])
        as! [[String: Any]])
      return data
    }

    func fetchCodable(
      url: URL,
      codable: Codable.Type
    ) async throws -> Decodable {
      let (data, response) = try await URLSession.shared.data(from: url)
      if response.mimeType != "application/json" {
        throw API.Exception.notJson
      }
      let decoder = JSONDecoder()
      let result = try decoder.decode(LoginResponse.self, from: data)
      return result
    }
  }

}
