//
//  ContentView.swift
//  tashak
//
//  Created by Alex on 16/09/2021.
//

import CoreStore
import SwiftUI

struct ApiLoadingView: View {
  @ObservedObject var api = API.Adapter
  private var indicator = ProgressIndicator()
  
  var body: some View {
    VStack {
      HStack {
        Text(api.loading.rawValue)
          .font(Theme.Font.desc)
        indicator
          .font(Theme.Font.Control.button)
          .font(Theme.Font.desc)
        Spacer()
      }.brightness(2.0)
        .padding()
      Spacer()
    }
  }
}
