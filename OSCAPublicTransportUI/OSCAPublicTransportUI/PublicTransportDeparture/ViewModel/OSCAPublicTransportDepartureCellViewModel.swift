//
//  OSCAPublicTransportDepartureCellViewModel.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 29.05.22.
//

import OSCAPublicTransport
import Foundation

public final class OSCAPublicTransportDepartureCellViewModel {
  
  let departure: OSCADeparturesForLocation.Stop.Departure
  
  // MARK: Initializer
  public init(departure: OSCADeparturesForLocation.Stop.Departure) {
    self.departure = departure
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
  
  var vehicle: OSCAPublicTransportVehicle {
    let typeOfTransport = departure.product?.klazz ?? 0
    return OSCAPublicTransportVehicle(type: typeOfTransport)
  }
  
  var departureTime: String { departure.departure.localFormatTime() }
  
  var duration: String {
    if let departure = departure.departure {
      
      let formatter = DateComponentsFormatter()
      formatter.unitsStyle = .short
      formatter.allowedUnits = [.hour, .minute]
      formatter.zeroFormattingBehavior = .dropLeading
      
      if let duration = formatter.string(from: departure.timeIntervalSinceNow) {
        return duration
      }
      else { return "---" }
    }
    else { return "---" }
  }
  
  var drivingDestination: String {
    return departure.destination ?? "---"
  }
  
  // MARK: Localized Strings
  
  var drivingDestinationTitle: String { NSLocalizedString(
    "public_transport_driving_destination_title",
    bundle: self.bundle,
    comment: "The title before driving destination") }
}

// MARK: - INPUT. View event methods
extension OSCAPublicTransportDepartureCellViewModel {
  func fill() -> Void {}
}
