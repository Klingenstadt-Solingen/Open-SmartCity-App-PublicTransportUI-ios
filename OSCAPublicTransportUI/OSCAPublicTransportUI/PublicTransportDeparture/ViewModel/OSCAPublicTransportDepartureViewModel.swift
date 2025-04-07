//
//  OSCAPublicTransportDepartureViewModel.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 18.05.22.
//  Reviewed by Stephan Breidenbach on 22.06.22
//

import OSCAPublicTransport
import Foundation

public struct OSCAPublicTransportDepartureViewModel {
  
  enum Section { case departures }
  
  let stop: OSCADeparturesForLocation.Stop
  
  // MARK: Initializer
  public init(stop: OSCADeparturesForLocation.Stop) {
    self.stop = stop
  }
  
  // MARK: - OUTPUT
  
  var screenTitle: String { self.stop.name ?? "" }
  
  var departures : [OSCADeparturesForLocation.Stop.Departure] {
    guard let departures = self.stop.departures else { return [] }
    return departures
  }
}

// MARK: - Input, view event methods
extension OSCAPublicTransportDepartureViewModel {
  func viewDidLoad() {}
}
