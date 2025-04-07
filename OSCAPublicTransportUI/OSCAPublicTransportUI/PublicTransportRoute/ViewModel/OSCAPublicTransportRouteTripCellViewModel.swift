//
//  OSCAPublicTransportRouteTripCellViewModel.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 04.06.22.
//  Reviewed by Stephan Breidenbach on 09.06.22.
//

import OSCAPublicTransport
import OSCAEssentials
import Foundation

public final class OSCAPublicTransportRouteTripCellViewModel {
  
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
  
  var line: String { trip.transportation?.number ?? "" }
  
  var vehicle: OSCAPublicTransportVehicle {
    guard let typeOfTransportation = trip.transportation?.product?.klazz
    else { return OSCAPublicTransportVehicle(type: 0) }
    return OSCAPublicTransportVehicle(type: typeOfTransportation)
  }
  
  var duration: String {
    guard let tripDuration = trip.duration else { return "---" }
    return tripDuration.toTimeWithUnit()
  }// end var duration
  
  var departureTime: String {
    guard let origin = self.trip.origin
    else { return "---" }
    return origin.departureTimePlannedString
  }// end var departureTime
  
  var destinationTime: String {
    guard let origin      = trip.origin,
          let duration    = trip.duration
    else { return "---" }
    let dateAdded   = origin.departureTimePlanned.add(seconds: duration).localFormatTime()
    return dateAdded
  }// end var destinationTime
  
  var countOfStops: String {
    guard let count = trip.stopSequence?.count else { return "" }
    return "\(count) \(stops)"
  }
  
  // MARK: Localized Strings
  
  var tomorrow: String { NSLocalizedString(
    "public_transport_tomorrow",
    bundle: self.bundle,
    comment: "Show text for tomorrow") }
  var stops: String { NSLocalizedString(
    "public_transport_stop",
    bundle: self.bundle,
    comment: "Show text for stop") }
}


// MARK: - Input, view event methods
extension OSCAPublicTransportRouteTripCellViewModel {
  func fill() {}
}
