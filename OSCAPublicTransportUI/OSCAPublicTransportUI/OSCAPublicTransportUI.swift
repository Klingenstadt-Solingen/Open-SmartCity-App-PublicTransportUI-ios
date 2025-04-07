//
//  OSCAPublicTransportUI.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 05.05.22.
//  Reviewed by Stephan Breidenbach on 07.06.22.
//  Reviewed by Stephan Breidenbach on 22.06.22
//

import OSCAEssentials
import OSCAPublicTransport
import UIKit

public protocol OSCAPublicTransportUIModuleConfig: OSCAUIModuleConfig {
  var cornerRadius: Double { get set }
  var shadow: OSCAShadowSettings { get set }
  var fontConfig: OSCAFontConfig { get set }
  var colorConfig: OSCAColorConfig { get set }
  var deeplinkScheme: String { get set }
}// end public protocol OSCAPublicTransportUIModuleConfig

public struct OSCAPublicTransportUIDependencies {
  let dataModule     : OSCAPublicTransport
  let moduleConfig   : OSCAPublicTransportUIConfig
  let analyticsModule: OSCAAnalyticsModule?
  
  public init(dataModule: OSCAPublicTransport,
              moduleConfig: OSCAPublicTransportUIConfig,
              analyticsModule: OSCAAnalyticsModule? = nil
  ) {
    self.dataModule = dataModule
    self.moduleConfig   = moduleConfig
    self.analyticsModule = analyticsModule
  }// end public init
}// end public struct OSCAPublicTransportUIDependencies

public struct OSCAPublicTransportUIConfig: OSCAPublicTransportUIModuleConfig {
  /// module title
  public var title: String?
  public var externalBundle: Bundle?
  public var cornerRadius: Double             = 10.0
  public var shadow: OSCAShadowSettings       = OSCAShadowSettings(opacity: 0.3,
                                                                   radius: 10,
                                                                   offset: CGSize(width: 0, height: 2))
  public var fontConfig: OSCAFontConfig       = OSCAFontSettings()
  public var colorConfig: OSCAColorConfig     = OSCAColorSettings()
  /// default location
  public var defaultLocation   : OSCAGeoPoint = OSCAGeoPoint(latitude: 51.17724517968174, longitude: 7.084675786820801)
  /// app deeplink scheme URL part before `://`
  public var deeplinkScheme      : String     = "solingen"
  
  public init(title: String?                        , //
              externalBundle: Bundle? = nil,
              cornerRadius: Double            = 10.0, //
              shadow: OSCAShadowSettings      = OSCAShadowSettings(opacity: 0.3,
                                                                   radius: 10,
                                                                   offset: CGSize(width: 0, height: 2)), //
              fontConfig: OSCAFontConfig      = OSCAFontSettings(), //
              colorConfig: OSCAColorConfig    = OSCAColorSettings(), //
              defaultLocation: OSCAGeoPoint   = OSCAGeoPoint(latitude: 51.17724517968174, longitude: 7.084675786820801),
              deeplinkScheme: String = "solingen"
  ) {
    self.title = title
    self.externalBundle = externalBundle
    self.cornerRadius = cornerRadius
    self.shadow = shadow
    self.fontConfig = fontConfig
    self.colorConfig = colorConfig
    self.deeplinkScheme = deeplinkScheme
  }// end init
}// end public struct OSCAPublicTransportUIConfig

public struct OSCAPublicTransportUI: OSCAUIModule {
  /// module DI container
  private var moduleDIContainer: OSCAPublicTransportUIDIContainer!
  public var version: String = "1.0.3"
  public var bundlePrefix: String = "de.osca.publicTransport.ui"
  
  public internal(set) static var configuration: OSCAPublicTransportUIConfig!
  /// module `Bundle`
  ///
  /// **available after module initialization only!!!**
  public internal(set) static var bundle: Bundle!
  
  /**
   create module and inject module dependencies
   - Parameter mduleDependencies: module dependencies
   */
  public static func create(with moduleDependencies: OSCAPublicTransportUIDependencies) -> OSCAPublicTransportUI {
    var module: Self = Self.init(config: moduleDependencies.moduleConfig)
    module.moduleDIContainer = OSCAPublicTransportUIDIContainer(dependencies: moduleDependencies)
    return module
  }
  
  /// public initializer with module configuration
  /// - Parameter config: module configuration
  public init(config: OSCAUIModuleConfig) {
#if SWIFT_PACKAGE
    Self.bundle = Bundle.module
#else
    guard let bundle: Bundle = Bundle(identifier: self.bundlePrefix) else { fatalError("Module bundle not initialized!") }
    Self.bundle = bundle
#endif
    guard let extendedConfig = config as? OSCAPublicTransportUIConfig else { fatalError("Config couldn't be initialized!")}
    OSCAPublicTransportUI.configuration = extendedConfig
  }
  
  /**
   public module interface `getter`for `OSCAPublicTransportFlowCoordinator`
   - Parameter router: router needed or the navigation graph
   */
  public func getPublicTransportFlowCoordinator(router: Router) -> OSCAPublicTransportFlowCoordinator {
    let flow = self.moduleDIContainer.makePublicTransportFlowCoordinator(router: router)
    return flow
  }
}// end public struct OSCAPublicTransportUI
