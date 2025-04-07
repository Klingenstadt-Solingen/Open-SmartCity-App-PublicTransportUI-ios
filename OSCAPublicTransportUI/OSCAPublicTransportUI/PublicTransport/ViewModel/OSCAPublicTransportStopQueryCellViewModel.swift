//
//  OSCAPublicTransportStopQueryCellViewModel.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 29.05.22.
//

import OSCAPublicTransport
import Foundation

public final class OSCAPublicTransportStopQueryCellViewModel {

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
}

// MARK: - INPUT. View event methods
extension OSCAPublicTransportStopQueryCellViewModel {
  func fill() {}
}
