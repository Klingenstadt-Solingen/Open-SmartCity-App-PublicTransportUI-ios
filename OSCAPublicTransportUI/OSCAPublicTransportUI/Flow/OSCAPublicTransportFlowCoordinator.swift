//
//  OSCAPublicTransportFlowCoordinator.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 06.05.22.
//  Reviewed by Stephan Breidenbach on 22.06.22
//

import OSCAEssentials
import OSCAPublicTransport

public protocol OSCAPublicTransportFlowCoordinatorDependencies {
  var deeplinkScheme: String { get }
  func makeOSCAPublicTransportViewController(actions: OSCAPublicTransportViewModelActions, _ from: String?,
                                             _ to: String?,
                                             _ dateTime: String?,
                                             _ arrDep: String?) -> OSCAPublicTransportViewController
  func makeOSCAPublicTransportDepartureViewController(stop: OSCADeparturesForLocation.Stop) -> OSCAPublicTransportDepartureViewController
  func makeOSCAPublicTransportRouteViewController(journey: OSCAJourney) -> OSCAPublicTransportRouteViewController
  
  func makeOSCAPublicTransportStationSearch(actions: OSCAPublicTransportStationSearchViewModelActions, title: String?) -> OSCAPublicTransportStationSearchViewController
}

public final class OSCAPublicTransportFlowCoordinator: Coordinator {
  /**
   `children`property for conforming to `Coordinator` protocol is a list of `Coordinator`s
   */
  public var children: [Coordinator] = []
  
  /**
   router injected via initializer: `router` will be used to push and pop view controllers
   */
  public let router: Router
  
  /**
   dependencies injected via initializer DI conforming to the `OSCAPublicTransportFlowCoordinatorDependencies` protocol
   */
  let dependencies: OSCAPublicTransportFlowCoordinatorDependencies
  
  /**
   public transport view controller `OSCAPublicTransportViewController`
   */
  private weak var publicTransportVC: OSCAPublicTransportViewController?
  private weak var stationSearchVC: OSCAPublicTransportStationSearchViewController?
  
  public init(router: Router, dependencies: OSCAPublicTransportFlowCoordinatorDependencies) {
    self.router = router
    self.dependencies = dependencies
  }
  
  // MARK: - Public Transport Actions
  
  private func showPublicTransportDeparture(stop: OSCADeparturesForLocation.Stop) -> Void {
    let vc = self.dependencies.makeOSCAPublicTransportDepartureViewController(stop: stop)
    self.router.present(vc,
                        animated: true,
                        onDismissed: nil)
  }
  
  private func showPublicTransportRoute(journey: OSCAJourney) -> Void {
    let vc = self.dependencies.makeOSCAPublicTransportRouteViewController(journey: journey)
    self.router.present(vc,
                        animated: true,
                        onDismissed: nil)
  }
  
  func showPublicTransportMain(animated: Bool,
                               onDismissed: (() -> Void)?) -> Void {
    let actions = OSCAPublicTransportViewModelActions(
      showPublicTransportDeparture: self.showPublicTransportDeparture,
      showPublicTransportRoute: self.showPublicTransportRoute,
      showStationSearch: { title, didSelectStationCallback in
        self.showStationSelection(animated: true, title: title, didSelect: didSelectStationCallback)
      }
    )
    
    let vc = self.dependencies.makeOSCAPublicTransportViewController(actions: actions, nil, nil, nil, nil)
    self.router.present(vc,
                        animated: animated,
                        onDismissed: onDismissed)
    self.publicTransportVC = vc
  }// end func showPublicTransportMain
    
    func showPublicTransportMainDeeplink(with from: String? = nil,
                                          _ to: String? = nil,
                                          _ dateTime: String? = nil,
                                          _ arrDep: String? = nil,
                                          onDismissed:(() -> Void)?) -> Void {
      let actions = OSCAPublicTransportViewModelActions(
        showPublicTransportDeparture: self.showPublicTransportDeparture,
        showPublicTransportRoute: self.showPublicTransportRoute,
        showStationSearch: { title, didSelectStationCallback in
          self.showStationSelection(animated: true, title: title, didSelect: didSelectStationCallback)
        }
      )
      
      let vc = self.dependencies.makeOSCAPublicTransportViewController(actions: actions, from, to, dateTime, arrDep)
      self.router.present(vc,
                          animated: true,
                          onDismissed: onDismissed)
      self.publicTransportVC = vc
    }// end func showPublicTransportMain
  
  public func present(animated: Bool, onDismissed: (() -> Void)?) {
    // Note: here we keep strong reference with actions, this way this flow do not need to be strong referenced
    showPublicTransportMain(animated: animated,
                            onDismissed: onDismissed)
  }// end public func present
  
  func showStationSelection(animated: Bool,
                              title: String?,
                              didSelect: ((OSCAStop) -> Void)?,
                               onDismissed: (() -> Void)? = nil) -> Void {
    let actions = OSCAPublicTransportStationSearchViewModelActions(
      onStationSelected: { selectedStation in
        didSelect?(selectedStation)
        self.stationSearchVC?.dismiss(animated: true)
      }
    )
    
    let vc = self.dependencies.makeOSCAPublicTransportStationSearch(actions: actions, title: title)
    self.router.presentModalViewController(vc, animated: animated, onDismissed: onDismissed)
    self.stationSearchVC = vc
  }
}
