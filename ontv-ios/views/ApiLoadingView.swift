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

struct CustomCircularProgressViewStyle: ProgressViewStyle {
  func makeBody(configuration: Configuration) -> some View {
    ZStack {
      Circle()
        .trim(from: 0.0, to: CGFloat(configuration.fractionCompleted ?? 0))
        .stroke(Color.blue, style: StrokeStyle(lineWidth: 3, dash: [10, 5]))
        .rotationEffect(.degrees(-90))
        .frame(width: 200)

      if let fractionCompleted = configuration.fractionCompleted {
        Text(
          fractionCompleted < 1
            ? "Completed \(Int((configuration.fractionCompleted ?? 0) * 100))%"
            : "Done!"
        )
        .fontWeight(.bold)
        .foregroundColor(fractionCompleted < 1 ? .orange : .green)
        .frame(width: 180)
      }
    }
  }
}

struct ApiLoadingView: View {
  @ObservedObject var api = API.Adapter
  private var indicator = ProgressIndicator()

  var body: some View {
    VStack {
      if api.inProgress {
        Spacer()
        ProgressView("Intializing application", value: api.progressValue, total: api.progressTotal)
          .progressViewStyle(RoundedRectProgressViewStyle())
      }
      else {
        HStack {
          Text(api.loading.rawValue)
            .font(Theme.Font.desc)
          indicator
            .font(Theme.Font.Control.button)
            .font(Theme.Font.desc)
          Spacer()
        }.brightness(2.0)
          .padding()
      }
      Spacer()
    }
  }
}
