//
//  ContentView.swift
//  tashak
//
//  Created by Alex on 16/09/2021.
//

import CoreStore
import SwiftUI

struct RoundedRectProgressViewStyle: ProgressViewStyle {
  func makeBody(configuration: Configuration) -> some View {
    HStack {
      Spacer()
      ZStack(alignment: .leading) {
        RoundedRectangle(cornerRadius: 14)
          .frame(width: 500, height: 50)
          .foregroundColor(.primary)
          .overlay(Color.black.opacity(0.5)).cornerRadius(14)

        RoundedRectangle(cornerRadius: 14)
          .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * 500, height: 50)
          .foregroundColor(.accentColor)

        Text(
          CGFloat(configuration.fractionCompleted ?? 0) < 1
            ? "Loading \(Int((configuration.fractionCompleted ?? 0) * 100))%"
            : "Done!"
        )
        .font(Theme.Font.progress).textCase(.lowercase)
        .frame(width: 500, height: 35)

      }
      Spacer()
    }
    .padding()
  }
}

struct ApiInitProgress: View {
  @ObservedObject var api = API.Adapter
  private var indicator = ProgressIndicator()

  var body: some View {
    VStack {
      Spacer()
      ProgressView("Intializing application", value: api.progressValue, total: api.progressTotal)
        .progressViewStyle(RoundedRectProgressViewStyle())
      Spacer()
    }
  }
}
