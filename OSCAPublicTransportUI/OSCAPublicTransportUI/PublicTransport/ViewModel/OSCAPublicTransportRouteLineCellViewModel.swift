//
//  OSCAPublicTransportRouteLineCellViewModel.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 01.06.22.
//

import OSCAPublicTransport
import Foundation

public final class OSCAPublicTransportRouteLineCellViewModel {
  
  let trip: OSCAJourney.Trip
  
  // MARK: Initializer
  public init(_ trip: OSCAJourney.Trip) {
    self.trip = trip
  }
  
  // MARK: - OUTPUT
  
  var line: String { trip.transportation?.number ?? "" }
  var vehicle: OSCAPublicTransportVehicle {
    guard let typeOfTransportation = trip.transportation?.product?.klazz
    else { return OSCAPublicTransportVehicle(type: 0) }
    return OSCAPublicTransportVehicle(type: typeOfTransportation)
  }
}

// MARK: - INPUT. View event methods
extension OSCAPublicTransportRouteLineCellViewModel {
  func fill() {}
}
