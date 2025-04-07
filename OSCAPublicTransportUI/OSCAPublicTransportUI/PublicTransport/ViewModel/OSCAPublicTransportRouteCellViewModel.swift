//
//  OSCAPublicTransportRouteCellViewModel.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 01.06.22.
//

import OSCAPublicTransport
import Foundation

public final class OSCAPublicTransportRouteCellViewModel {
  
  enum Section { case lines }
  
  let publicTransportViewModel: OSCAPublicTransportViewModel
  let journey: OSCAJourney
  let row: Int
  
  // MARK: Initializer
  public init(viewModel: OSCAPublicTransportViewModel,
              journey: OSCAJourney,
              at row: Int) {
    self.publicTransportViewModel = viewModel
    self.journey = journey
    self.row = row
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
  
  var journeyDuration: String {
    guard let trips = journey.trips else { return "" }
    var seconds: Int = 0
    for trip in trips {
      seconds = seconds + (trip.duration ?? 0)
    }
    return seconds.toTimeWithUnit()
  }
  
  var departureInfo: String {
    let formatter = DateComponentsFormatter()
    formatter.formattingContext = .standalone
    formatter.unitsStyle = .short
    formatter.allowedUnits = [.hour, .minute]
    formatter.zeroFormattingBehavior = .dropLeading
    
    guard let departureTime = journey.trips?[0].origin?.departureTimePlanned?.timeIntervalSinceNow,
          let departureLocation = journey.trips?[0].origin?.name
    else { return "" }
    let departureAsolute = abs(departureTime)
    guard let formattedDeparture = formatter.string(from: departureAsolute) else { return "" }
    
    let departureTimeFormatted = departureTime >= 0
      ? "\(startDepartureTime): \(formattedDeparture)"
      : "\(startDepartureTimePast): \(formattedDeparture)"
    let departureText = "\(departureTimeFormatted)\n\(startDepartureLocation): \(departureLocation)"
    
    return departureText
  }
  
  // MARK: Localized Strings
  
  var startDepartureTime: String { NSLocalizedString(
    "public_transport_start_departure_time_title",
    bundle: self.bundle,
    comment: "The title for starting time of the journey") }
  var startDepartureTimePast: String { NSLocalizedString(
    "public_transport_start_departure_time_title_past",
    bundle: self.bundle,
    comment: "The title for starting time of the journey in the past") }
  var startDepartureLocation: String { NSLocalizedString(
    "public_transport_start_departure_location_title",
    bundle: self.bundle,
    comment: "The title for starting location of the journey") }
}

// MARK: - INPUT. View event methods
extension OSCAPublicTransportRouteCellViewModel {
  func fill() {}
}
