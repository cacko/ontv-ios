//
//  LivescoreTicker.swift
//  ontv
//
//  Created by Alex on 19/11/2021.
//

import CoreStore
import Foundation

extension Livescore {

  func toggleTicker(
    _ completion: @escaping (AsynchronousDataTransaction.Result<Void>) -> Void
  ) async throws {
    Livescore.dataStack.perform(
      asynchronous: { (transaction) -> Void in

        guard let livescore = transaction.fetchExisting(self) else {
          return
        }

        livescore.in_ticker = (livescore.in_ticker - 1) * -1

      },
      completion: { result in completion(result) }
    )
  }

}
