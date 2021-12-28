//
//  Thumb.swift
//  craptv
//
//  Created by Alex on 07/11/2021.
//

import Foundation

extension Schedule {
  
  struct EventThumb: Validity {
    var name: String = ""
    var thumbUrl: URL {
      API.Endpoint.EventThumb(event: self.name)
    }
    var icon: Icon {
      Icon(self.thumbUrl.absoluteString)
    }
    
    var isValid: Bool {
      name.count > 0
    }
  }
  
  var eventThumb: EventThumb {
    EventThumb(name: self.name)
  }
}
