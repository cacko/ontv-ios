//
//  StreamIconView.swift
//  StreamIconView
//
//  Created by Alex on 13/10/2021.
//

import Foundation
import Kingfisher
import SwiftUI

enum StreamTitleView {
  struct TitleView<Content: View>: View {
    let content: Content
    private let icon: Icon
    private let iconUrl: URL

    init(
      _ iconUrl: URL,
      @ViewBuilder content: () -> Content
    ) {
      self.iconUrl = iconUrl
      self.icon = Icon(iconUrl.absoluteString)
      self.content = content()
    }

    var body: some View {
      Label {
        content
      } icon: {
        KFImage(iconUrl)
          .cacheOriginalImage()
          .setProcessor(
            DownsamplingImageProcessor(size: .init(width: 50, height: 21))
          ).onSuccess { _ in
            self.icon.hasIcon = true
          }.onFailure { _ in
            self.icon.hasIcon = false
          }.resizable()
          .frame(width: self.icon.hasIcon ? 50 : 0, height: 21, alignment: .center)
      }.labelStyle(.titleAndIcon)
    }
  }

  struct IconView: View {
    private let iconUrl: URL
    private let icon: Icon

    init(
      _ iconUrl: URL
    ) {
      self.iconUrl = iconUrl
      icon = Icon(iconUrl.absoluteString)
    }

    var body: some View {
      Label {
      } icon: {
        KFImage(iconUrl)
          .cacheOriginalImage()
          .setProcessor(
            DownsamplingImageProcessor(size: .init(width: 50, height: 21))
          )
          .onSuccess { _ in
            self.icon.hasIcon = true
          }.onFailure { _ in
            self.icon.hasIcon = false
          }.resizable()
          .frame(width: self.icon.hasIcon ? 50 : 0, height: 21, alignment: .center)
      }.labelStyle(.iconOnly)
    }
  }
}
