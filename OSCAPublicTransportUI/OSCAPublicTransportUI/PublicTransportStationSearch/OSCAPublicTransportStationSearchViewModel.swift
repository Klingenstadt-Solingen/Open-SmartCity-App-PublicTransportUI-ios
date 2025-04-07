//
//  OSCAPublicTransportStationSearchViewModel.swift
//  OSCAPublicTransportUI
//
//  Created by Igor Dias on 27.09.23.
//

import Foundation
import Combine
import OSCAPublicTransport
import CoreLocation
import MapKit
import OSCAEssentials

public enum OSCAPublicTransportStationSearchViewModelError: Error, Equatable {
  case stationFetch
}

public enum OSCAPublicTransportStationSearchViewModelState: Equatable {
  case loading
  case finishedLoading
  case error(OSCAPublicTransportStationSearchViewModelError)
}

public struct OSCAPublicTransportStationSearchViewModelActions {
  let onStationSelected: (OSCAStop) -> Void
}

public enum OSCAPublicTransportStationSearchViewModelData: Equatable {
  case stationResult
}

public final class OSCAPublicTransportStationSearchViewModel: ObservableObject {
  
  public let dataModule: OSCAPublicTransport
  private let actions: OSCAPublicTransportStationSearchViewModelActions?
  private var bindings = Set<AnyCancellable>()
  
  
  @Published private(set) var searchResults: [OSCAStop] = []
  @Published private(set) var nearbyStations: [OSCAStop] = []
  @Published private(set) var searchState: SearchState = .loading
  
  public let title: String?
  
  public init(
    dataModule: OSCAPublicTransport,
    actions: OSCAPublicTransportStationSearchViewModelActions,
    title: String?
  ) {
    self.dataModule = dataModule
    self.actions = actions
    self.title = title
  }
}

public extension OSCAPublicTransportStationSearchViewModel {
  var suggestedStopsText: String { NSLocalizedString(
    "public_transport_suggested_stops_label",
    bundle: OSCAPublicTransportUI.bundle,
    comment: "") }
  
  var searchResultText: String { NSLocalizedString(
    "public_transport_search_result_label",
    bundle: OSCAPublicTransportUI.bundle,
    comment: "") }
  
  var searchText: String { NSLocalizedString(
    "public_transport_search_title",
    bundle: OSCAPublicTransportUI.bundle,
    comment: "") }
  
  var searchEmptyResultText: String { NSLocalizedString(
    "public_transport_search_result_empty_label",
    bundle: OSCAPublicTransportUI.bundle,
    comment: "") }
  
  var loadingText: String { NSLocalizedString(
    "public_transport_search_loading",
    bundle: OSCAPublicTransportUI.bundle,
    comment: "") }
}

public extension OSCAPublicTransportStationSearchViewModel {
  func viewDidLoad() {
    fetchStopsNearby(userCoordinates)
  }
  
  private var userCoordinates: OSCAGeoPoint {
    var coordinates: OSCAGeoPoint
    if let location = LocationManager.shared.userLocation {
      coordinates = OSCAGeoPoint(location)
    } else {
      coordinates = OSCAPublicTransportUI.configuration.defaultLocation
    }
    return coordinates
  }
  
  private func fetchStopsNearby(_ coordinates: OSCAGeoPoint) {
    self.dataModule
      .fetchStops(nearby: coordinates)
      .sink { completion in
        switch completion {
        case .finished:
          break
          
        case .failure:
          self.searchState = .emptyResults
        }
        
      } receiveValue: { nearby in
        DispatchQueue.main.async {
          self.nearbyStations = nearby.stops ?? []
          if(self.searchState == .loading) {
            self.searchState = .showSuggested
          }
        }
      }
      .store(in: &bindings)
  }
  
  func searchStations(_ searchString: String) {
    guard searchString.count > 3 else {
      self.searchState = .showSuggested
      return
    }
    self.dataModule
      .stops(for: searchString)
      .sink { completion in
        switch completion {
        case .finished:
          break
          
        case .failure:
          break
        }
        
      } receiveValue: { stations in
        DispatchQueue.main.async {
          self.searchResults = stations
          self.searchState = stations.count > 0 ? .showResults : .emptyResults
        }
      }
      .store(in: &bindings)
  }
  
  func clearSearch() {
    self.searchResults = []
    self.searchState = .showSuggested
  }
  
  func didSelectStation(station: OSCAStop) {
    self.actions?.onStationSelected(station)
  }
  
}

extension OSCAPublicTransportStationSearchViewModel {
  public enum SearchState {
    case showSuggested
    case showResults
    case emptyResults
    case loading
  }
}
