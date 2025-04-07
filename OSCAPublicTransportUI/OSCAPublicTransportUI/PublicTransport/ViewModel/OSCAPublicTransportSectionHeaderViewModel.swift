//
//  OSCAPublicTransportSectionHeaderViewModel.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 29.05.22.
//

import Foundation

public final class OSCAPublicTransportSectionHeaderViewModel {
  
  let publicTransportViewModel: OSCAPublicTransportViewModel
  
  // MARK: Initializer
  public init(viewModel: OSCAPublicTransportViewModel) {
    self.publicTransportViewModel = viewModel
  }
  
  // MARK: OUTPUT
  
  var title: String {
    switch publicTransportViewModel.visibleSection {
    case .nearby:
      return publicTransportViewModel.nearbyStopsTitle
    case .query:
      return publicTransportViewModel.searchSuggestionsTitle
      
    case .routes:
      return publicTransportViewModel.routeConnectionTitle
    case nil:
      return ""
    }
  }
}

// MARK: - INPUT. View event methods
extension OSCAPublicTransportSectionHeaderViewModel {
  func fill() {}
}
