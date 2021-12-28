//
//  Bundle.swift
//  ontv
//
//  Created by Alex on 10/11/2021.
//

import Foundation

extension Bundle {
  var releaseVersionNumber: String {
    return infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
  }
  var buildVersionNumber: String {
    return infoDictionary?["CFBundleVersion"] as? String ?? "0"
  }
  var releaseVersionNumberPretty: String {
    return "v\(releaseVersionNumber )"
  }
}
