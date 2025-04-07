//
//  OSCAJourney+Formats.swift
//  OSCAPublicTransportUI
//
//  Created by Stephan Breidenbach on 08.06.22.
//

import Foundation
import OSCAPublicTransport
import OSCAEssentials

public extension OSCAJourney.Trip.Stop {
  var departureTimePlannedString: String {
    return self.departureTimePlanned.localFormatTime()
  }// end var departureTimePlannedString
}// end public extension OSCAJourney.Trip.Stop
