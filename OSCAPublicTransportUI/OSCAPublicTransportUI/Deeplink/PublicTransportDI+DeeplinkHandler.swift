//
//  PublicTransportDI+DeeplinkHandler.swift
//  OSCAPublicTransportUI
//
//  Created by Stephan Breidenbach on 08.09.22.
//

import Foundation

extension OSCAPublicTransportUIDIContainer {
  var deeplinkScheme: String {
    return self
      .dependencies
      .moduleConfig
      .deeplinkScheme
  }// end var deeplinkScheme
}// end extension final class OSCAPublicTransportUIDIContainer
