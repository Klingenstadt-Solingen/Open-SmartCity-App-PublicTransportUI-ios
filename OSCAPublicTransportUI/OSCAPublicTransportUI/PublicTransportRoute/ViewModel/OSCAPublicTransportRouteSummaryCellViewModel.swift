//
//  OSCAPublicTransportRouteSummaryCellViewModel.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 03.06.22.
//

import OSCAPublicTransport
import Foundation

public final class OSCAPublicTransportRouteSummaryCellViewModel {
  
  let journey: OSCAJourney
  
  // MARK: Initializer
  public init(journey: OSCAJourney) {
    self.journey = journey
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
  
  var departureDate: Date? { journey.trips?[0].origin?.departureTimePlanned }
  
  
  var departureTime: String {
   
//    guard let date = departureDate else { return "" }
//    if date.isToday {
//      return date.toString(.custom("HH:mm"))
//    } else if date.isTomorrow {
//      return "\(tomorrow) \(date.toString(.custom("HH:mm")))"
//    } else {
//      return date.toString(.custom("dd.MM. HH:mm"))
//    }
    guard let departureString = self.journey.trips?.first?.origin?.departureTimePlannedString
    else { return "" }
    return departureString
  }// end var departureTime
  
  var departureInfo: String {
    let formatter = DateComponentsFormatter()
    formatter.formattingContext = .standalone
    formatter.unitsStyle = .short
    formatter.allowedUnits = [.hour, .minute]
    formatter.zeroFormattingBehavior = .dropLeading
    
    guard let departureTime = departureDate?.timeIntervalSinceNow else { return "" }
    let departureAsolute = abs(departureTime)
    guard let formattedDeparture = formatter.string(from: departureAsolute) else { return "" }
    
    return departureTime >= 0
      ? "\(moveDepartureTime) \(formattedDeparture)"
      : "\(moveDepartureTimePast) \(formattedDeparture)"
  }
  
  // MARK: Localized Strings
  
  var moveDepartureTime: String { NSLocalizedString(
    "public_transport_move_departure_time_title",
    bundle: self.bundle,
    comment: "The title to start moving") }
  var moveDepartureTimePast: String { NSLocalizedString(
    "public_transport_move_departure_time_title_past",
    bundle: self.bundle,
    comment: "The title to start moving in the past") }
  var tomorrow: String { NSLocalizedString(
    "public_transport_tomorrow",
    bundle: self.bundle,
    comment: "Show text for tomorrow") }
}

// MARK: - Input, view event methods
extension OSCAPublicTransportRouteSummaryCellViewModel {
  func fill() {}
}
