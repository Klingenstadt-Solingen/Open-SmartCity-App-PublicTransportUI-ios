//
//  OSCAPublicTransportUIDIContainer.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 06.05.22.
//  Reviewed by Stephan Breidenbach on 22.06.22
//

import OSCAEssentials
import OSCAPublicTransport

/**
 Every isolated module feature will have its own Dependency Injection Container,
 to have one entry point where we can see all dependencies and injections of the module
 */
final class OSCAPublicTransportUIDIContainer {
  
  let dependencies: OSCAPublicTransportUIDependencies
  
  public init(dependencies: OSCAPublicTransportUIDependencies) {
    self.dependencies = dependencies
  }// end public init
  
  // MARK: - Public Transport
  func makeOSCAPublicTransportViewController(actions: OSCAPublicTransportViewModelActions) -> OSCAPublicTransportViewController {
    return OSCAPublicTransportViewController.create(with: makeOSCAPublicTransportViewModel(actions: actions))
  }// end func makeOSCAPublicTransportViewController
    
  func makeOSCAPublicTransportViewController(actions: OSCAPublicTransportViewModelActions, 
                                             _ from: String?, _ to: String?, _ dateTime: String?, _ arrDep: String?) -> OSCAPublicTransportViewController {
      return OSCAPublicTransportViewController.create(with: OSCAPublicTransportViewModel(dataModule: dependencies.dataModule, actions: actions, from: from, to: to, dateTime: dateTime, arrDep: arrDep))
  }// end func makeOSCAPublicTransportViewController
  
  func makeOSCAPublicTransportViewModel(actions: OSCAPublicTransportViewModelActions) -> OSCAPublicTransportViewModel {
    return OSCAPublicTransportViewModel(dataModule: dependencies.dataModule, actions: actions)
  }// end func makeOSCAPublicTransportViewModel
  
  // MARK: - Public Transport Departure
  func makeOSCAPublicTransportDepartureViewController(stop: OSCADeparturesForLocation.Stop) -> OSCAPublicTransportDepartureViewController {
    return OSCAPublicTransportDepartureViewController.create(with: makeOSCAPublicTransportDepartureViewModel(stop: stop))
  }// end func makeOSCAPublicTransportDepartureViewController
  
  func makeOSCAPublicTransportDepartureViewModel(stop: OSCADeparturesForLocation.Stop) -> OSCAPublicTransportDepartureViewModel {
    return OSCAPublicTransportDepartureViewModel(stop: stop)
  }// end func makeOSCAPublicTransportDepartureViewModel
  
  // MARK: - Public Transport Route
  func makeOSCAPublicTransportRouteViewController(journey: OSCAJourney) -> OSCAPublicTransportRouteViewController {
    return OSCAPublicTransportRouteViewController.create(with: makeOSCAPublicTransportRouteViewModel(journey: journey))
  }// end func makeOSCAPublicTransportRouteViewController
  
  func makeOSCAPublicTransportRouteViewModel(journey: OSCAJourney) -> OSCAPublicTransportRouteViewModel {
    return OSCAPublicTransportRouteViewModel(journey: journey)
  }// end func makeOSCAPublicTransportRouteViewModel
  
  // MARK: - Flow Coordinators
  func makePublicTransportFlowCoordinator(router: Router) -> OSCAPublicTransportFlowCoordinator {
    return OSCAPublicTransportFlowCoordinator(router: router, dependencies: self)
  }// end func makePublicTransportFlowCoordinator
}// end final class OSCAPublicTransportUIDIContainer

extension OSCAPublicTransportUIDIContainer: OSCAPublicTransportFlowCoordinatorDependencies {
  func makeOSCAPublicTransportStationSearch(actions: OSCAPublicTransportStationSearchViewModelActions, title: String?) -> OSCAPublicTransportStationSearchViewController {
    let viewModel = OSCAPublicTransportStationSearchViewModel(dataModule: self.dependencies.dataModule, actions: actions, title: title)
    return OSCAPublicTransportStationSearchViewController(with: viewModel)
  }
}
