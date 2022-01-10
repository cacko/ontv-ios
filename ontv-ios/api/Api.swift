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

  enum State {
    case loading, ready, error, loggedin, idle, boot
  }

  enum FetchType {
    case streams, schedule, epg, livescore, idle, leagues
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
    @Published var epgState: ProviderState = .notavail
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

    private var tasks: [Sendable] = []

    func login(username: String, password: String) async {
      self.username = username
      self.password = password
      await login()
    }

    func clean() {
      guard tasks.count > 0 else {
        return
      }
      //      tasks.forEach { $0.cancel() }
    }

    func fetch(_ type: API.FetchType) {
      Task.init {
        switch type {
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
      do {
        DispatchQueue.main.async {
          self.state = .loading
        }
        _ = try await self.updateUser()

        if Stream.isLoaded {
          DispatchQueue.main.async {
            self.state = .ready
            self.streamsState = .ready
            NotificationCenter.default.post(name: .updatestreams, object: nil)
          }
        }
        else {
          DispatchQueue.main.async {
            self.inProgress = true
          }
        }

        if League.needsUpdate {
          try await updateLeagues()
        }

        if Stream.needsUpdate {
          try await updateStreams()
        }

        if Schedule.needsUpdate {
          try await updateSchedule()
        }
        else {
          DispatchQueue.main.async {
            self.scheduleState = .ready
            NotificationCenter.default.post(name: .updateschedule, object: nil)
          }
        }
        NotificationCenter.default.post(name: .loaded, object: nil)
        if EPG.needsUpdate {
          try await self.updateEPG()
        }
        else {
          DispatchQueue.main.async {
            self.epgState = .loaded
            NotificationCenter.default.post(name: .updateepg, object: nil)
          }
        }
      }
      catch let error {
        DispatchQueue.main.async {
          self.state = .error
          self.error = API.Exception.invalidLogin(error.localizedDescription)
        }
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
              self.state = .error
              self.error = API.Exception.subscriptionExpired(self.expires)
              return
            }
          }
          NotificationCenter.default.post(name: .loggedin, object: nil)
          self.state = .loggedin
          self.loggedIn = true
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
          self.state = .loggedin
          self.loggedIn = true
          NotificationCenter.default.post(name: .loggedin, object: nil)
        }
      }
    }

    func updateSchedule() async throws {
      guard self.scheduleState != .loading else {
        return
      }
      DispatchQueue.main.async {
        self.scheduleState = .loading
        self.fetchType = .schedule
      }
      try await Schedule.fetch(url: Endpoint.Schedule) { _ in
        let tc = Task.init {
          do {
            try await Schedule.delete(Schedule.clearQuery)
            Defaults[.scheduleUpdated] = Date()
            DispatchQueue.main.async {
              self.scheduleState = .ready
              self.fetchType = .idle
            }
            //            self.tasks.remove(tc)
            NotificationCenter.default.post(name: .updateschedule, object: nil)
          }
          catch let error {
            DispatchQueue.main.async {
              self.scheduleState = .ready
              self.fetchType = .idle
            }
            //            self.tasks.remove(tc)
            logger.error("\(error.localizedDescription)")
          }
        }
        self.tasks.append(tc)
      }
    }

    func updateStreams() async throws {
      guard self.streamsState != .loading else {
        return
      }

      DispatchQueue.main.async {
        self.loading = .stream
        self.streamsState = .loading
        self.fetchType = .streams
      }
      try await Category.fetch(url: Endpoint.Categories) { _ in
        let tc = Task.init {
          do {
            try await Category.delete(Category.clearQuery)
            //            self.tasks(tc)
            try await Stream.fetch(url: Endpoint.Streams) { _ in
              let ts = Task.init {
                do {
                  try await Stream.delete(Stream.clearQuery)
                  NotificationCenter.default.post(name: .updatestreams, object: nil)
                  DispatchQueue.main.async {
                    self.loading = .loaded
                    self.fetchType = .idle
                    self.streamsState = .ready
                    self.inProgress = false
                    Defaults[.streamsUpdated] = Date()
                  }
                  //                  self.tasks.remove(ts)
                }
                catch let error {
                  DispatchQueue.main.async {
                    self.loading = .loaded
                    self.fetchType = .idle
                    self.streamsState = .ready
                  }
                  //                  self.tasks.remove(ts)
                  logger.error(">>> \(error.localizedDescription)")
                }
              }
              self.tasks.append(ts)
            }
          }
          catch let error {
            logger.error("??? \(error.localizedDescription)")
          }
        }
        self.tasks.append(tc)
      }
    }

    func updateEPG() async throws {
      guard self.epgState != .loading else {
        return
      }

      DispatchQueue.main.async {
        self.loading = .epg
        self.epgState = .loading
        self.fetchType = .epg
      }

      try await EPG.fetch(url: Endpoint.EPG) { _ in
        let te = Task.detached {
          do {
            try await EPG.delete(EPG.clearQuery)
            Defaults[.epgUpdated] = Date()
            NotificationCenter.default.post(name: .updateepg, object: nil)
            DispatchQueue.main.async {
              self.epgState = .loaded
              self.loading = .loaded
              self.fetchType = .idle
            }
            //            self.tasks.remove(te)
          }
          catch let error {
            DispatchQueue.main.async {
              self.epgState = .loaded
              self.loading = .loaded
              self.fetchType = .idle
            }
            //            self.tasks.remove(te)
            logger.error("\(error.localizedDescription)")
          }
        }
        self.tasks.append(te)
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

      DispatchQueue.main.async {
        self.loading = .leagues
        self.leaguesState = .loading
        self.fetchType = .leagues
      }

      try await League.fetch(url: Endpoint.Leagues) { _ in
        let te = Task.detached {
          Defaults[.leaguesUpdated] = Date()
          NotificationCenter.default.post(name: .leagues_updates, object: nil)
          DispatchQueue.main.async {
            self.leaguesState = .ready
            self.fetchType = .idle
          }
          //            self.tasks.remove(te)
        }
        self.tasks.append(te)
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
