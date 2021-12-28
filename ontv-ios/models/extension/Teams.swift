//
//  Teams.swift
//  craptv
//
//  Created by Alex on 04/11/2021.
//

import Foundation

extension Schedule {

  struct Team: Validity {
    var id: String = ""
    var badgeUrl: URL {
      API.Endpoint.TeamBadge(team: self.id)
    }
    var icon: Icon {
      Icon(self.badgeUrl.absoluteString)
    }

    var isValid: Bool {
      id.count > 0
    }
  }

  var homeTeam: Team {
    Team(id: self.home_team)
  }

  var awayTeam: Team {
    Team(id: self.away_team)
  }
}
