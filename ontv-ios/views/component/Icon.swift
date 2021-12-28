//
//  Icon.swift
//  craptv
//
//  Created by Alex on 03/11/2021.
//

import Foundation

class Icon: ObservableObject {
  let url: URL

  @Published var hasIcon: Bool = false

  init(
    _ icon: String
  ) {
    url = URL(string: icon) ?? URL(fileURLWithPath: "")
    hasIcon = icon.count > 0
  }
}
