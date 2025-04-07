//
//  OSCAPublicTransportRouteViewModel.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 03.06.22.
//  Reviewed by Stephan Breidenbach on 22.06.22
//

import OSCAEssentials
import OSCAPublicTransport
import Foundation

public struct OSCAPublicTransportRouteViewModel {
  let journey: OSCAJourney
  
  // MARK: Initializer
  public init(journey: OSCAJourney) {
    self.journey = journey
  }// end public init
  
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
  
  var numberOfRowsInSection: Int { (journey.trips?.count ?? 0) + 1 }
  
  // MARK: Localized Strings
  
  var screenTitle: String { NSLocalizedString(
    "public_transport_route_screen_title",
    bundle: self.bundle,
    comment: "The screen title") }
}// end public struct OSCAPublicTransportRouteViewModel

// MARK: - Input, view event methods
extension OSCAPublicTransportRouteViewModel {
  func viewDidLoad() {}
}
