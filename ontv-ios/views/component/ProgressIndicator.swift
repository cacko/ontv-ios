//
//  ProgressIndicator.swift
//  ProgressIndicator
//
//  Created by Alex on 05/10/2021.
//

import Foundation
import SwiftUI

struct ProgressIndicator: UIViewRepresentable {
  typealias UIViewType = UIActivityIndicatorView

  private let v: UIActivityIndicatorView = UIActivityIndicatorView(frame: .zero)

  func makeUIView(context: Self.Context) -> Self.UIViewType {
    v.startAnimating()
    return v
  }

  func start() {
    let _ = self.v.startAnimating()
    return
  }

  func stop() {
    let _ = self.v.startAnimating()
    return
  }

  func updateUIView(_ nsView: Self.UIViewType, context: Self.Context) {}
}
