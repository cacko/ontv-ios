//
//  ScrollingView.swift
//  craptv
//
//  Created by Alex on 06/11/2021.
//

import Foundation
import SwiftUI

extension Animation {
  static var instant: Animation {
    return .linear(duration: 0.01)
  }
}

struct ScrollingView<Content: View>: View {

  private let direction: Axis.Set
  private let columns: [GridItem]!
  private var spacing: CGFloat = 5
  private let onPress: () -> Void = {}

  let content: Content

  init(
    _ direction: Axis.Set = .vertical,
    @ViewBuilder content: () -> Content
  ) {
    self.direction = direction
    self.columns = nil
    self.spacing = 5
    self.content = content()
  }

  init(
    direction: Axis.Set,
    columns: [GridItem],
    spacing: CGFloat,
    @ViewBuilder content: () -> Content
  ) {
    self.direction = direction
    self.columns = columns
    self.spacing = spacing
    self.content = content()
  }

  var body: some View {
    ScrollView(direction, showsIndicators: false) {
      if direction == .vertical {
        if columns != nil {
          LazyVGrid(columns: self.columns, spacing: self.spacing) {
            content
          }
        }
        else {
          if columns != nil {
            LazyHGrid(rows: self.columns, spacing: self.spacing) {
              content
            }
          }
          else {
            LazyVStack {
              content
            }
          }
        }
      }
      else {
        LazyHStack {
          content
        }
      }
    }
  }
}
