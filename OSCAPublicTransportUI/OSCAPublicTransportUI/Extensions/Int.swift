//
//  Int.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 03.06.22.
//

import Foundation

extension Int {
  func toTimeWithUnit() -> String {
    let hour: String = NSLocalizedString(
      "public_transport_hour_unit",
      bundle: OSCAPublicTransportUI.configuration.externalBundle == nil
        ? OSCAPublicTransportUI.bundle
        : OSCAPublicTransportUI.configuration.externalBundle!,
      comment: "The unit for hours")
    let minute: String = NSLocalizedString(
      "public_transport_minute_unit",
      bundle: OSCAPublicTransportUI.configuration.externalBundle == nil
        ? OSCAPublicTransportUI.bundle
        : OSCAPublicTransportUI.configuration.externalBundle!,
      comment: "The unit for minutes")
    
    let (h,m) = (self / 3600, (self % 3600) / 60)
    return h == 0
      ? "\(m) \(minute)"
      : "\(h) \(hour) \(m) \(minute)"
  }
}
