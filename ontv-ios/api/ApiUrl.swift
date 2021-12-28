//
//  ApiUrl.swift
//  craptv
//
//  Created by Alex on 23/10/2021.
//

import Foundation

extension API {
  
  enum Endpoint {
    
    static var endpoint: String {
      "\(API.Adapter.server_info.server_protocol)://\(API.Adapter.server_info.url):\(API.Adapter.server_info.port)"
    }
    
    static var BaseAction: String {
      "\(endpoint)/player_api.php?username=\(API.Adapter.username)&password=\(API.Adapter.password)"
    }
    
    static var BaseResource: String {
      "\(endpoint)/live/\(API.Adapter.username)/\(API.Adapter.password)"
    }
    
    static var Login: URL {
      URL(
        string: BaseAction
      )
      ?? URL(fileURLWithPath: "")
    }
    
    static var Streams: URL {
      URL(
        string:
          "\(BaseAction)&action=get_live_streams"
      ) ?? URL(fileURLWithPath: "")
    }
    
    static var Categories: URL {
      URL(
        string:
          "\(BaseAction)&action=get_live_categories"
      ) ?? URL(fileURLWithPath: "")
    }
    
    static var Schedule: URL {
      URL(string: "https://ontv.cacko.net/api/data/schedule.json") ?? URL(fileURLWithPath: "")
    }
    
    static var EPG: URL {
      URL(string: "https://ontv.cacko.net/api/data/xmltv.json") ?? URL(fileURLWithPath: "")
    }
    
    static func Stream(_ id: Int64) -> URL {
      URL(string: "\(BaseResource)/\(id).ts")
      ?? URL(fileURLWithPath: "")
    }
    
    static func Icon(id: Int64, epg: String = "") -> URL {
      guard
        var urlBuilder = URLComponents(
          string:
            "https://ontv.cacko.net"
        )
      else {
        fatalError("")
      }
      urlBuilder.path =
      "/api/assets/channel/logo/\(String(id))/\(epg.count == 0 ? "default" : epg).png"
      return urlBuilder.url!
    }
    
    static func TeamBadge(team: String) -> URL {
      guard
        var urlBuilder = URLComponents(
          string: "https://ontv.cacko.net"
        )
      else {
        fatalError("")
      }
      urlBuilder.path = "/api/assets/team/badge/\(team).png"
      return urlBuilder.url!
    }
    
    static func EventThumb(event: String) -> URL {
      guard
        var urlBuilder = URLComponents(
          string: "https://ontv.cacko.net"
        )
      else {
        fatalError("")
      }
      urlBuilder.path = "/api/assets/event/thumb/\(event).png"
      return urlBuilder.url!
    }
    
    static var Sports: URL {
      URL(string: "https://ontv.cacko.net/api/data/sports.json") ?? URL(fileURLWithPath: "")
    }
    
    static func SportIcon(id: String) -> URL {
      guard
        var urlBuilder = URLComponents(
          string: "https://ontv.cacko.net"
        )
      else {
        fatalError("")
      }
      urlBuilder.path = "/api/assets/sport/icon/\(id).png"
      return urlBuilder.url!
    }
    
    static var Livescores: URL {
      URL(string: "https://ontv.cacko.net/api/data/livescores.json") ?? URL(fileURLWithPath: "")
    }
  }
  
}
