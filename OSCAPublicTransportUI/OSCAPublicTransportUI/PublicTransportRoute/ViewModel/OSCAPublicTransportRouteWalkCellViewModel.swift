//
//  OSCAPublicTransportRouteWalkCellViewModel.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 04.06.22.
//

import OSCAPublicTransport
import Foundation

public final class OSCAPublicTransportRouteWalkCellViewModel {
  
  let trip: OSCAJourney.Trip
  
  // MARK: Initializer
  public init(trip: OSCAJourney.Trip) {
    self.trip = trip
  }
  
  // MARK: - OUTPUT
  
  /**
   Use this to get access to the __Bundle__ delivered from this module's configuration parameter __externalBundle__.
   - Returns: The __Bundle__ given to this module's configuration parameter __externalBundle__. If __externalBundle__ is __nil__, The module's own __Bundle__ is returned instead.
   */
  var bundle: Bundle = {
    if let bundle = OSCAPublicTransportUI.configuration.externalBundle {
      return bundle
    }
    else { return OSCAPublicTransportUI.bundle }
  }()
  
  var footpathInfo: String {
    guard let duration = trip.duration else { return "" }
    return "\(duration.toTimeWithUnit()) \(footpath)"
  }
  
  // MARK: Localized Strings
  
  var footpath: String { NSLocalizedString(
    "public_transport_footpath",
    bundle: self.bundle,
    comment: "The screen title") }
}

// MARK: - Input, view event methods
extension OSCAPublicTransportRouteWalkCellViewModel {
  func fill() {}
}
