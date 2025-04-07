//
//  OSCAPublicTransportStopNearbyCellViewModel.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 29.05.22.
//

import OSCAPublicTransport
import Foundation

public final class OSCAPublicTransportStopNearbyCellViewModel {
  
  let publicTransportViewModel: OSCAPublicTransportViewModel
  let stop: OSCAStop
  let row: Int
  
  // MARK: Initializer
  public init(viewModel: OSCAPublicTransportViewModel,
              stop: OSCAStop,
              at row: Int) {
    self.publicTransportViewModel = viewModel
    self.stop = stop
    self.row = row
  }
  
  // MARK: - OUTPUT
  
  var duration: String {
    var time = "--"
    if let duration = stop.duration {
      time = "\(duration)"
    }
    return time
  }
  var lines: String {
    var lineNumbers = ""
    for departureStop in publicTransportViewModel.stopsWithDepartures {
      if stop.id == departureStop.id {
        if let lines = departureStop.lines {
          for line in lines {
            lineNumbers = lineNumbers.isEmpty
              ? "\(line)"
              : "\(lineNumbers), \(line)"
          }
        }
      }
    }
    return lineNumbers
  }
}

// MARK: - INPUT. View event methods
extension OSCAPublicTransportStopNearbyCellViewModel {
  func fill() {}
}
