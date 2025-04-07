//
//  OSCAPublicTransportUITests.swift
//  OSCAPublicTransportUITests
//
//  Created by Ömer Kurutay on 05.05.22.
//  Reviewed by Stephan Breidenbach on 07.06.22.
//
#if canImport(XCTest) && canImport(OSCATestCaseExtension)
import XCTest
@testable import OSCAPublicTransportUI
import OSCAEssentials
import OSCANetworkService
import OSCAPublicTransport
import OSCATestCaseExtension

class OSCAPublicTransportUITests: XCTestCase {
  static let moduleVersion = "1.0.3"
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    try super.setUpWithError()
  }// end override func setUpWithError
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    try super.tearDownWithError()
  }// end override func tearDownWithError
  
  func testModuleInit() throws -> Void {
    let uiModule = try makeDevUIModule()
    XCTAssertNotNil(uiModule)
    XCTAssertEqual(uiModule.version, OSCAPublicTransportUITests.moduleVersion)
    XCTAssertEqual(uiModule.bundlePrefix, "de.osca.publicTransport.ui")
    let bundle = OSCAPublicTransportUI.bundle
    XCTAssertNotNil(bundle)
    let uiBundle = OSCAPublicTransportUI.bundle
    XCTAssertNotNil(uiBundle)
    let configuration = OSCAPublicTransportUI.configuration
    XCTAssertNotNil(configuration)
    XCTAssertNotNil(self.devPlistDict)
    XCTAssertNotNil(self.productionPlistDict)
  }// end func testModuleInit
  
}// end class OSCAPublicTransportUITests

// MARK: - factory methods
extension OSCAPublicTransportUITests {
  
  public func makeDevModuleDependencies() throws -> OSCAPublicTransportDependencies {
    let networkService = try makeDevNetworkService()
    let userDefaults = try makeUserDefaults(domainString: "de.osca.publicTransport.ui")
    let dependencies = OSCAPublicTransportDependencies(networkService: networkService,
                                                       userDefaults: userDefaults)
    return dependencies
  }// end public func makeDevModuleDependencies
  
  public func makeDevModule() throws -> OSCAPublicTransport {
    let devDependencies = try makeDevModuleDependencies()
    let module = OSCAPublicTransport.create(with: devDependencies)
    return module
  }// end public func makeDevModule
  
  public func makeProductionModuleDependencies() throws -> OSCAPublicTransportDependencies {
    let networkService = try makeProductionNetworkService()
    let userDefaults = try makeUserDefaults(domainString: "de.osca.publicTransport.ui")
    let dependencies = OSCAPublicTransportDependencies(networkService: networkService,
                                                       userDefaults: userDefaults)
    return dependencies
  }// end public func makeProductionModuleDependencies
  
  public func makeProductionModule() throws -> OSCAPublicTransport {
    let productiondependencies = try makeProductionModuleDependencies()
    let module = OSCAPublicTransport.create(with: productiondependencies)
    return module
  }// end public func makeProductionModule
  
  public func makeUIModuleConfig() throws -> OSCAPublicTransportUIConfig {
    let defaultLocation = try self.getDevDefaultLocation()
    return OSCAPublicTransportUIConfig(title: "OSCAPublicTransportUI",
                                       cornerRadius: 10.0,
                                       shadow: OSCAShadowSettings(opacity: 0.2,
                                                                  radius: 10,
                                                                  offset: CGSize(width: 0, height: 2)),
                                       fontConfig: OSCAFontSettings(),
                                       colorConfig: OSCAColorSettings(),
                                       defaultLocation: defaultLocation)
  }// end public func makeUIModuleConfig
  
  public func makeDevUIModuleDependencies() throws -> OSCAPublicTransportUIDependencies {
    let module = try makeDevModule()
    let uiConfig = try makeUIModuleConfig()
    return OSCAPublicTransportUIDependencies(dataModule: module,
                                             moduleConfig: uiConfig)
  }// end public func makeDevUIModuleDependencies
  
  public func makeDevUIModule() throws -> OSCAPublicTransportUI {
    let devUIDependencies = try makeDevUIModuleDependencies()
    let uiModule = OSCAPublicTransportUI.create(with: devUIDependencies)
    return uiModule
  }// end public func makeDevUIModule
  
  public func makeDevUIModuleDIContainer() throws -> OSCAPublicTransportUIDIContainer {
    let devUIDependencies = try makeDevUIModuleDependencies()
    let uiModuleDIContainer = OSCAPublicTransportUIDIContainer(dependencies: devUIDependencies)
    return uiModuleDIContainer
  }// end public func makeDevUIModuleDIContainer
  
  public func makeProductionUIModuleDependencies() throws -> OSCAPublicTransportUIDependencies {
    let module = try makeProductionModule()
    let uiConfig = try makeUIModuleConfig()
    return OSCAPublicTransportUIDependencies(dataModule: module,
                                             moduleConfig: uiConfig)
  }// end public func makeProductionUIModuleDependencies
  
  public func makeProductionUIModule() throws -> OSCAPublicTransportUI {
    let productionUIDependencies = try makeProductionUIModuleDependencies()
    let uiModule = OSCAPublicTransportUI.create(with: productionUIDependencies)
    return uiModule
  }// end public func makeProductionUIModule
}// end extension class OSCAPublicTransportUITests
#endif
