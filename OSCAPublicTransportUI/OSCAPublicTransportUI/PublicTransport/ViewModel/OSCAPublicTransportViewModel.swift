//
//  OSCAPublicTransportViewModel.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 06.05.22.
//  Reviewed by Stephan Breidenbach on 22.06.22
//

import OSCAEssentials
import OSCAPublicTransport
import Foundation
import Combine

public struct OSCAPublicTransportViewModelActions {
    let showPublicTransportDeparture: (OSCADeparturesForLocation.Stop) -> Void
    let showPublicTransportRoute: (OSCAJourney) -> Void
    let showStationSearch: (String, @escaping (OSCAStop) -> Void) -> Void
}

public enum OSCAPublicTransportViewModelError: Error, Equatable {
    case publicTransportFetch
}

public enum OSCAPublicTransportViewModelState: Equatable {
    case loadingNearby
    case loadingQuery
    case loadingRoute
    case finishedLoadingNearby
    case finishedLoadingQuery
    case finishedLoadingRoute
    case error(OSCAPublicTransportViewModelError)
    case waitingForQuery
}

public final class OSCAPublicTransportViewModel {
    
    enum Section { case nearby, query, routes }
    public enum TravelPosition { case departure, destination }
    
    private let dataModule: OSCAPublicTransport
    private let actions: OSCAPublicTransportViewModelActions?
    private var bindings = Set<AnyCancellable>()
    
    // MARK: Initializer
    public init(dataModule: OSCAPublicTransport,
                actions: OSCAPublicTransportViewModelActions, from: String? = nil,
                to: String? = nil,
                dateTime: String? = nil,
                arrDep: String? = nil) {
        self.selectedDepartureId = from
        self.selectedDestinationId = to
        self.dataModule = dataModule
        self.actions = actions
        tripDate = dateTime ?? Date().toUTCString()
        tripType = arrDep == "arr" ? .arrival : .departure
        if(self.selectedDepartureId != nil && self.selectedDestinationId != nil){
            // nach den namen suchen
            state = .loadingRoute
            self.fetchStopsById([self.selectedDepartureId!,self.selectedDestinationId!])
        } else {
            
        }
    }// end public init
    
    // MARK: - OUTPUT
    
    @Published private(set) var state: OSCAPublicTransportViewModelState = .waitingForQuery
    @Published var journeys: [OSCAJourney] = []
    @Published var departureText: String = ""
    @Published var destinationText: String = ""
    
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
    
    var stopsNearby: [OSCAStop] = []
    var stopsQueried: [OSCAStop] = []
    var stopsWithDepartures: [OSCADeparturesForLocation.Stop] = []
    var visibleSection: Section? = nil
    var focusedSearchField: TravelPosition = .departure
    var selectedDepartureId: String? = nil
    var selectedDepartureGeopoint: [Double]? = nil
    var selectedDestinationId: String? = nil
    var selectedDestinationGeopoint: [Double]? = nil
    var tripType: OSCATripParameter.Trip.Types = .departure
    var tripDate: String = Date().toUTCString()
    
    var numberOfItemsInSection: Int {
        switch visibleSection {
        case .nearby: return stopsNearby.count
        case .query : return stopsQueried.count
        case .routes: return journeys.count
        case nil: return 0
        }
    }
    
    // MARK: Localized Strings
    
    var screenTitle: String { NSLocalizedString(
        "public_transport_screen_title",
        bundle: self.bundle,
        comment: "The screen title") }
    var departurePlaceholder: String { NSLocalizedString(
        "public_transport_placeholder_departure",
        bundle: self.bundle,
        comment: "The placeholder text for the departure field") }
    var destinationPlaceholder: String { NSLocalizedString(
        "public_transport_placeholder_destination",
        bundle: self.bundle,
        comment: "The placeholder text for the destination field") }
    var departureTitle: String { NSLocalizedString(
        "public_transport_departure_title",
        bundle: self.bundle,
        comment: "The departure title for the travel time") }
    var arrivalTitle: String { NSLocalizedString(
        "public_transport_arrival_title",
        bundle: self.bundle,
        comment: "The arrival title for the travel time") }
    var currentTimeTitle: String { NSLocalizedString(
        "public_transport_current_time_title",
        bundle: self.bundle,
        comment: "The current time title for the travel time") }
    var searchTitle: String { NSLocalizedString(
        "public_transport_search_title",
        bundle: self.bundle,
        comment: "The search title for the travel") }
    var nearbyStopsTitle: String { NSLocalizedString(
        "public_transport_nearby_stops_title",
        bundle: self.bundle,
        comment: "The title for stops nearby") }
    var searchSuggestionsTitle: String { NSLocalizedString(
        "public_transport_search_suggestions_title",
        bundle: self.bundle,
        comment: "The title for search suggestions") }
    var routeConnectionTitle: String { NSLocalizedString(
        "public_transport_route_connection_title",
        bundle: self.bundle,
        comment: "The title for the route connections") }
    var minuteTitle: String { NSLocalizedString(
        "public_transport_minute_unit",
        bundle: self.bundle,
        comment: "The unit for minutes") }
    var myLocationTitle: String { NSLocalizedString(
        "public_transport_my_location_title",
        bundle: self.bundle,
        comment: "The title for using current location") }
    var nearbyStopsLoadingTitle: String { NSLocalizedString(
        "public_transport_nearby_stops_loading_title",
        bundle: self.bundle,
        comment: "The text for the section header of nearby stops while loading") }
    var queriedStopsLoadingTitle: String { NSLocalizedString(
        "public_transport_queried_stops_loading_title",
        bundle: self.bundle,
        comment: "The text for the section header of queried stops while loading") }
    var swiftSpinnerTitle: String { NSLocalizedString(
        "public_transport_swift_spinner_title",
        bundle: self.bundle,
        comment: "The text for the spinner while loading for routes") }
    
    var selectOriginTitle: String { NSLocalizedString(
        "public_transport_select_origin_title",
        bundle: self.bundle,
        comment: "") }
    
    var selectDestinationTitle: String { NSLocalizedString(
        "public_transport_select_destination_title",
        bundle: self.bundle,
        comment: "") }
    
    // MARK: - Private
    
    @objc private func userLocationDidChange(_ notification: NSNotification) {
        
    }
    
    private func updateStopsNearby() {
        var coordinates: OSCAGeoPoint
        if let location = LocationManager.shared.userLocation {
            coordinates = OSCAGeoPoint(location)
        } else {
            coordinates = self.defaultLocation
        }// end if
        state = .loadingNearby
        fetchStopsNearby(coordinates)
    }// end private func updateStopsNearby
    
    private func fetchStopsNearby(_ coordinates: OSCAGeoPoint) {
        self.dataModule
            .fetchStops(nearby: coordinates)
            .sink { completion in
                switch completion {
                case .finished:
                    self.fetchDepartures(for: coordinates)
                    
                case .failure:
                    self.state = .error(.publicTransportFetch)
                }
                
            } receiveValue: { nearby in
                self.visibleSection = .nearby
                guard let stops = nearby.stops else { return }
                self.stopsNearby = stops
            }
            .store(in: &bindings)
    }
    
    private func fetchDepartures(for location: OSCAGeoPoint) {
        self.dataModule
            .departures(for: location)
            .sink { completion in
                switch completion {
                case .finished:
                    self.state = .finishedLoadingNearby
                    
                case .failure:
                    self.state = .error(.publicTransportFetch)
                }
                
            } receiveValue: { departure in
                guard let stops = departure.stops else { return }
                self.stopsWithDepartures = stops
            }
            .store(in: &bindings)
    }
    
    private func fetchStops(with searchString: String) {
        self.dataModule
            .stops(for: searchString)
            .sink { completion in
                switch completion {
                case .finished:
                    self.state = .finishedLoadingQuery
                    
                case .failure:
                    self.state = .error(.publicTransportFetch)
                }
                
            } receiveValue: { stop in
                self.visibleSection = .query
                self.stopsQueried = stop
            }
            .store(in: &bindings)
    }
    
    private func fetchStopsById(_ stopIds: [String]) {
        state = .loadingRoute
        self.dataModule
            .fetchStopsByIds(ids: stopIds)
            .sink { completion in
                switch completion {
                case .finished:
                    self.state = .finishedLoadingQuery
                    
                case .failure:
                    self.state = .error(.publicTransportFetch)
                }
                
            } receiveValue: { stops in
                self.didSelectStation(stops[0],for: .departure)
                self.didSelectStation(stops[1],for: .destination)
            }
            .store(in: &bindings)
    }
    
    private func fetchJourneys() {
        let fromStop = OSCATripParameter.Location(
            stop: selectedDepartureId,
            geopoint: selectedDepartureGeopoint)
        let toStop = OSCATripParameter.Location(
            stop: selectedDestinationId,
            geopoint: selectedDestinationGeopoint)
        let trip = OSCATripParameter.Trip(type: tripType,
                                          date: tripDate,
                                          count: nil)
        let parameter = OSCATripParameter(from:  fromStop,
                                          to:    toStop,
                                          trip:  trip)
        state = .loadingRoute
        self.dataModule
            .trips(for: parameter)
            .sink { completion in
                switch completion {
                case .finished:
                    self.state = .finishedLoadingRoute
                    
                case .failure:
                    self.state = .error(.publicTransportFetch)
                }
                
            } receiveValue: { journeys in
                self.visibleSection = .routes
                self.journeys = journeys.filter { $0.minutesUntilDeparture > 0 }
            }
            .store(in: &bindings)
    }
}

// MARK: - Input, view event methods
extension OSCAPublicTransportViewModel {
    func viewDidLoad() {
        LocationManager.shared.askForPermissionIfNeeded()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userLocationDidChange(_:)),
            name: .userLocationDidChange,
            object: nil)
    }
    
    func viewDidAppear() {
        
    }
    
    func searchFieldEditingChanged(with text: String) {
        switch focusedSearchField {
        case .departure:
            selectedDepartureId = nil
            selectedDepartureGeopoint = nil
            
        case .destination:
            selectedDestinationId = nil
            selectedDestinationGeopoint = nil
        }
        
        if !text.isEmpty {
            bindings.removeAll()
            state = .loadingQuery
            fetchStops(with: text)
        }
    }
    
    func routeSwapButtonTouch(_ departure: String, _ destination: String) {
        self.departureText = destination
        self.destinationText = departure
        
        swap(&selectedDepartureId, &selectedDestinationId)
        swap(&selectedDepartureGeopoint, &selectedDestinationGeopoint)
    }
    
    func keyboardMyLocationButtonTouch() {
        if let location = LocationManager.shared.userLocation {
            let geopoint = [location.coordinate.longitude,
                            location.coordinate.latitude]
            switch focusedSearchField {
            case .departure:
                selectedDepartureGeopoint = geopoint
                selectedDepartureId = nil
                departureText = myLocationTitle
                
            case .destination:
                selectedDestinationGeopoint = geopoint
                selectedDestinationId = nil
                destinationText = myLocationTitle
            }
        }
    }
    
    func travelSegmentedControlTouch(index selectedSegment: Int) {
        tripType = selectedSegment == 0
        ? .departure
        : .arrival
    }
    
    func currentTimeButtonTouch(_ date: Date) {
        tripDate = date.toUTCString()
    }
    
    func datePickerValueChanged(_ date: Date) {
        tripDate = date.toUTCString()
    }// end func datePickerValueChanged date
    
    func searchButtonTouch() {
        if selectedDepartureId != nil || selectedDepartureGeopoint != nil,
           selectedDestinationId != nil || selectedDestinationGeopoint != nil
        {
            fetchJourneys()
        }
    }
    
    func didSelectRow(at index: Int) {
        switch visibleSection {
        case nil: return
        case .nearby:
            let stop = stopsNearby[index]
            guard let name = stop.name else { return }
            
            switch focusedSearchField {
            case .departure:
                selectedDepartureId = stop.properties?.stopId
                selectedDepartureGeopoint = nil
                departureText = name
                
            case .destination:
                selectedDestinationId = stop.properties?.stopId
                selectedDestinationGeopoint = nil
                destinationText = name
            }
            
        case .query:
            let stop = stopsQueried[index]
            guard let name = stop.name else { return }
            
            switch focusedSearchField {
            case .departure:
                selectedDepartureId = stop.properties?.stopId
                selectedDepartureGeopoint = nil
                departureText = name
                
            case .destination:
                selectedDestinationId = stop.properties?.stopId
                selectedDestinationGeopoint = nil
                destinationText = name
            }
            
        case .routes:
            actions?.showPublicTransportRoute(journeys[index])
        }
    }
    
    func accessoryButtonTapped(for row: Int) {
        switch visibleSection {
        case .nearby:
            guard !stopsNearby.isEmpty,
                  !stopsWithDepartures.isEmpty
            else { return }
            
            for departureStop in stopsWithDepartures {
                if stopsNearby[row].id == departureStop.id {
                    actions?.showPublicTransportDeparture(departureStop)
                }
            }
            
        case .query, .routes, nil: break
        }
    }
}

extension OSCAPublicTransportViewModel {
    /// default geo location
    var defaultLocation: OSCAGeoPoint {
        return OSCAPublicTransportUI.configuration.defaultLocation
    }// end defaultLocation
}// end extension public final class OSCAPublicTransportViewModel

extension OSCAPublicTransportViewModel {
    public func openStationSearch(for position: TravelPosition) {
        let title = position == .departure ? self.selectOriginTitle : self.selectDestinationTitle
        self.actions?.showStationSearch(title) { selectedStation in
            self.didSelectStation(selectedStation, for: position)
        }
    }
    
    private func didSelectStation(_ station: OSCAStop, for position: TravelPosition) {
        switch position {
        case .departure:
            selectedDepartureId = station.properties?.stopId ?? station.id
            selectedDepartureGeopoint = nil
            departureText = station.name ?? ""
            print("Set \(position) to \(station.name), stopId = \(station.properties?.stopId)")
        case .destination:
            selectedDestinationId = station.properties?.stopId ?? station.id
            selectedDestinationGeopoint = nil
            destinationText = station.name ?? ""
            print("Set \(position) to \(station.name), stopId = \(station.properties?.stopId)")
        }
    }
}
