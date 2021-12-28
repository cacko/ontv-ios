//
//  ButtonStyle.swift
//  ButtonStyle
//
//  Created by Alex on 01/10/2021.
//

import SwiftUI

struct PushButtonStyle: ButtonStyle {

  private var font: Font

  init(
    _ font: Font = .body
  ) {
    self.font = font
  }

  func makeBody(configuration: Self.Configuration) -> some View {
    VStack {
      configuration.label
        .font(font).padding()

    }.cornerRadius(10.0)
  }
}

struct CustomButtonStyle: ButtonStyle {

  private var font: Font

  init(
    _ font: Font = .body
  ) {
    self.font = font
  }

  func makeBody(configuration: Self.Configuration) -> some View {
    VStack {
      configuration.label
        .padding(0)
        .font(font)
    }
  }
}

struct ListButtonStyle: ButtonStyle {

  func makeBody(configuration: Self.Configuration) -> some View {
    VStack {
      configuration.label
        .padding(0)
    }
  }
}
