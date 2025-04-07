//
//  OSCAPublicTransportViewModelTests.swift
//  OSCAPublicTransportUITests
//
//  Created by Stephan Breidenbach on 07.06.22.
//

import Foundation
import Combine
import XCTest
import OSCAEssentials
import OSCAPublicTransport
@testable import OSCAPublicTransportUI

class OSCAPublicTransportViewModelTests: XCTestCase {
  private var cancellables: Set<AnyCancellable>!
  var moduleTests: OSCAPublicTransportUITests!
  var module: OSCAPublicTransportUI!
  var moduleDIContainer: OSCAPublicTransportUIDIContainer!
  var viewModelActions: OSCAPublicTransportViewModelActions!
  var sut: OSCAPublicTransportViewModel!
  var error: OSCAPublicTransportViewModelError?
  var loadingNearbyExpectation        : XCTestExpectation?
  var finishedLoadingNearbyExpectation: XCTestExpectation?
  var loadingQueryExpectation         : XCTestExpectation?
  var finishedLoadingQueryExpectation : XCTestExpectation?
  var loadingRouteExpectation         : XCTestExpectation?
  var finishedLoadingRouteExpectation : XCTestExpectation?
  var stopsWithDepartures: [OSCADeparturesForLocation.Stop]?
  var stopsQueried: [OSCAStop]?
  var journeys: [OSCAJourney]?
  
  override func setUpWithError() throws -> Void {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    // initialize cancellabels
    self.cancellables = []
    // init error
    self.error = nil
    
    // init module tests
    self.moduleTests = OSCAPublicTransportUITests()
    XCTAssertNotNil(self.moduleTests)
    // test module init
    XCTAssertNoThrow(try self.moduleTests.setUpWithError())
    XCTAssertNoThrow(try self.moduleTests.testModuleInit())
    // init module
    self.module = try self.moduleTests.makeDevUIModule()
    XCTAssertNotNil(self.module)
    // init module di container
    self.moduleDIContainer = try self.moduleTests.makeDevUIModuleDIContainer()
    XCTAssertNotNil(self.moduleDIContainer)
    // init view model actions
    self.viewModelActions = OSCAPublicTransportViewModelActions(
      showPublicTransportDeparture: self.showPublicTransportDeparture(for:),
      showPublicTransportRoute: self.showPublicTransportRoute(of:),
      showStationSearch: { query, completion in
        XCTAssertTrue(!query.isEmpty)
        XCTAssertNotNil(completion)
      })
    XCTAssertNotNil(self.viewModelActions)
    // init view model
    self.sut = self.moduleDIContainer.makeOSCAPublicTransportViewModel(actions: self.viewModelActions)
    XCTAssertNotNil(self.sut)
  }// end override func setUpWithError
  
  override func tearDownWithError() throws -> Void {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    try super.tearDownWithError()
    guard let cancellabels = self.cancellables
    else { return }
    if !cancellabels.isEmpty {
      for cancellable in cancellabels {
        cancellable.cancel()
      }// end for
      self.cancellables = nil
    }// end if
  }// end override func tearDownWithError
  
  func testInit() throws -> Void {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    // Any test you write for XCTest can be annotated as throws and async.
    // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
    // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    XCTAssertNotNil(self.sut)
    
  }// end func
  
  func testDefaultLocation() throws -> Void {
    XCTAssertNotNil(self.sut)
    var defaultLocationFromPlist: OSCAGeoPoint?
    XCTAssertNoThrow(defaultLocationFromPlist = try getDevDefaultLocation())
    guard let defaultLocationFromPlist = defaultLocationFromPlist
    else {
      XCTFail("Default location from plist init failed!"); return
    }// end guard
    XCTAssertEqual(self.sut.defaultLocation, defaultLocationFromPlist)
  }// end func testDefaultLocation
  
  func testFetchStopsNearBy() throws -> Void {
    XCTAssertNotNil(self.sut)
    // setup value handler for view model state
    setupHandler(with: self.sut, for: .Nearby)
    guard let loadingNearbyExpectation = self.loadingNearbyExpectation,
          let finishedLoadingNearbyExpectation = self.finishedLoadingNearbyExpectation
    else { XCTFail("Expectation init failed!"); return }
    // trigger view model
    self.sut.viewDidAppear()
    
    wait(for: [loadingNearbyExpectation,
               finishedLoadingNearbyExpectation], timeout: 20)
    XCTAssertNil(self.error)
    XCTAssertNotNil(self.stopsWithDepartures)
  }// end func testFetchStopsNearBy
  
  func testFetchStopsWithSearchString() throws -> Void {
    XCTAssertNotNil(self.sut)
    // setup value handler for view model state
    setupHandler(with: self.sut, for: .Query)
    guard let loadingNearbyExpectation = self.loadingNearbyExpectation,
          let loadingQueryExpectation = self.loadingQueryExpectation,
          let finishedLoadingQueryExpectation = self.finishedLoadingQueryExpectation
    else { XCTFail("Expectation init failed!"); return }
    // trigger view model
    self.sut.searchFieldEditingChanged(with: "Technologiezentrum")
    
    wait(for: [loadingNearbyExpectation,
               loadingQueryExpectation,
               finishedLoadingQueryExpectation], timeout: 20)
    XCTAssertNil(self.error)
    XCTAssertNotNil(self.stopsQueried)
  }// end func testFetchStopsWithSearchString
  
  func testFetchJourneysForDepartureDestination() throws -> Void {
    XCTAssertNotNil(self.sut)
    // setup value handler for view model state
    setupHandler(with: self.sut, for: .Route)
    guard let loadingNearbyExpectation = self.loadingNearbyExpectation,
          let loadingRouteExpectation = self.loadingRouteExpectation,
          let finishedLoadingRouteExpectation = self.finishedLoadingRouteExpectation
    else { XCTFail("Expectation init failed!"); return }
    // trigger view model
    // set trip type to departure
    self.sut.tripType = .departure
    // set departure id
    self.sut.selectedDepartureId = "20013870"
    XCTAssertNotNil(self.sut.selectedDepartureId)
    // set destination id
    self.sut.selectedDestinationId = "20013800"
    XCTAssertNotNil(self.sut.selectedDestinationId)
    // init now date and time
    let nowDate: Date = Date()
    // trigger date picker value changed
    self.sut.datePickerValueChanged(nowDate)
    // trigger search button touch
    self.sut.searchButtonTouch()
    
    wait(for: [loadingNearbyExpectation,
               loadingRouteExpectation,
               finishedLoadingRouteExpectation], timeout: 20)
    XCTAssertNil(self.error)
    XCTAssertNotNil(self.journeys)
  }// end testFetchJourneysForDepartureDestination
  
  func testDatePickerValueChanged() throws -> Void {
    XCTAssertNotNil(self.sut)
    let dateNow = Date()
    let dateIsoString = Date.ISOStringFromDate(date: dateNow)
    self.sut.datePickerValueChanged(dateNow)
    XCTAssertEqual(dateIsoString, self.sut.tripDate)
  }// end func testDatePickerValueChanged
}// end class OSCAPublicTransportViewModelTests

extension OSCAPublicTransportViewModelTests {
  enum State{
    case Nearby
    case Query
    case Route
  }// end enum OSCAPublicTransportViewModelTests.State
  
  private func showPublicTransportDeparture(for stop: OSCADeparturesForLocation.Stop) -> Void {
    XCTAssertNotNil(stop)
  }// end private func showPublicTransportDeparture
  
  private func showPublicTransportRoute(of journey: OSCAJourney) -> Void {
    XCTAssertNotNil(journey)
  }// end private func showPublicTransportRoute
  
  private func showStationSearch(query: String,
                                 completion: @escaping (OSCAStop) -> Void) -> Void {
    XCTAssertTrue(!query.isEmpty)
    XCTAssertNotNil(completion)
  }// end private func showStationSearch
  
  private func setupHandler(with viewModel: OSCAPublicTransportViewModel, for state: OSCAPublicTransportViewModelTests.State) {
    var stateValueHandler: (OSCAPublicTransportViewModelState) -> Void
    switch state {
    case .Nearby:
      // init expectations
      self.loadingNearbyExpectation         = self.expectation(description: "loading nearby expectation")
      self.loadingNearbyExpectation!.expectedFulfillmentCount = 2
      self.finishedLoadingNearbyExpectation = self.expectation(description: "finished loading nearby expectation")
      let stateLoadingNearby: () -> Void = {[weak self] in
        guard let `self` = self,
              let loadingNearbyExpectation = self.loadingNearbyExpectation else { return }
        loadingNearbyExpectation.fulfill()
      }// end let stateLoadingNearby
      let stateFinishedLoadingNearby: () -> Void = {[weak self] in
        guard let `self` = self,
              let finishedLoadingNearbyExpectation = self.finishedLoadingNearbyExpectation else { return }
        self.stopsWithDepartures = viewModel.stopsWithDepartures
        finishedLoadingNearbyExpectation.fulfill()
      }// end let stateFinishedLoadingNearby
      let stateError: (OSCAPublicTransportViewModelError) -> Void = {[weak self] error in
        guard let `self` = self else { return }
        self.error = error
      }// end let stateError
      stateValueHandler = { viewModelState in
        switch viewModelState {
        case .loadingNearby:
          stateLoadingNearby()
        case .finishedLoadingNearby:
          stateFinishedLoadingNearby()
        case let .error(error):
          stateError(error)
        default:
          XCTFail("ViewModel state handling failed!")
        }// end switch case
      }// end stateValueHandler
    case .Query:
      // init expectations
      self.loadingNearbyExpectation         = self.expectation(description: "loading nearby expectation")
      self.loadingQueryExpectation          = self.expectation(description: "loading query expectation")
      self.finishedLoadingQueryExpectation  = self.expectation(description: "finished loading query expectation")
      let stateLoadingNearby: () -> Void = {[weak self] in
        guard let `self` = self,
              let loadingNearbyExpectation = self.loadingNearbyExpectation else { return }
        loadingNearbyExpectation.fulfill()
      }// end let stateLoadingNearby
      let stateLoadingQuery: () -> Void = {[weak self] in
        guard let `self` = self,
              let loadingQueryExpectation = self.loadingQueryExpectation else { return }
        loadingQueryExpectation.fulfill()
      }// end let stateLoadingQuery
      let stateFinishedLoadingQuery: () -> Void = {[weak self] in
        guard let `self` = self,
              let finishedLoadingQueryExpectation = self.finishedLoadingQueryExpectation else { return }
        self.stopsQueried = viewModel.stopsQueried
        finishedLoadingQueryExpectation.fulfill()
      }// end let stateFinishedLoadingQuery
      let stateError: (OSCAPublicTransportViewModelError) -> Void = {[weak self] error in
        guard let `self` = self else { return }
        self.error = error
      }// end let stateError
      stateValueHandler = { viewModelState in
        switch viewModelState {
        case .loadingNearby:
          stateLoadingNearby()
        case .loadingQuery:
          stateLoadingQuery()
        case .finishedLoadingQuery:
          stateFinishedLoadingQuery()
        case let .error(error):
          stateError(error)
        default:
          XCTFail("ViewModel state handling failed!")
        }// end switch case
      }// end stateValueHandler
    case .Route:
      // init expectations
      self.loadingNearbyExpectation         = self.expectation(description: "loading nearby expectation")
      self.loadingRouteExpectation          = self.expectation(description: "loading route expectation")
      self.finishedLoadingRouteExpectation  = self.expectation(description: "finished loading route expectation")
      let stateLoadingNearby: () -> Void = {[weak self] in
        guard let `self` = self,
              let loadingNearbyExpectation = self.loadingNearbyExpectation else { return }
        loadingNearbyExpectation.fulfill()
      }// end let stateLoadingNearby
      let stateLoadingRoute: () -> Void = {[weak self] in
        guard let `self` = self,
              let loadingRouteExpectation = self.loadingRouteExpectation else { return }
        loadingRouteExpectation.fulfill()
      }// end let stateLoadingRoute
      let stateFinishedLoadingRoute: () -> Void = {[weak self] in
        guard let `self` = self,
              let finishedLoadingRouteExpectation = self.finishedLoadingRouteExpectation else { return }
        self.journeys = viewModel.journeys
        finishedLoadingRouteExpectation.fulfill()
      }// end let stateFinishedLoadingRoute
      let stateError: (OSCAPublicTransportViewModelError) -> Void = {[weak self] error in
        guard let `self` = self else { return }
        self.error = error
      }// end let stateError
      stateValueHandler = { viewModelState in
        switch viewModelState {
        case .loadingNearby:
          stateLoadingNearby()
        case .loadingRoute:
          stateLoadingRoute()
        case .finishedLoadingRoute:
          stateFinishedLoadingRoute()
        case let .error(error):
          stateError(error)
        default:
          XCTFail("ViewModel state handling failed!")
        }// end switch case
      }// end stateValueHandler
    }// end switch case
    viewModel.$state
      .receive(on: RunLoop.main)
      .sink(receiveValue: stateValueHandler)
      .store(in: &self.cancellables)
  }// end private func setupHandler with view model
}// end extension class OSCAPublicTransportViewModelTests
