// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// use local package path
let packageLocal: Bool = false

let oscaEssentialsVersion = Version("1.1.0")
let oscaTestCaseExtensionVersion = Version("1.1.0")
let swiftSpinnerVersion = Version("2.2.0")
let oscaPublicTransportVersion = Version("1.1.0")

let package = Package(
  name: "OSCAPublicTransportUI",
  defaultLocalization: "de",
  platforms: [.iOS(.v15)],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "OSCAPublicTransportUI",
      targets: ["OSCAPublicTransportUI"]),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
     // OSCAEssentials
    packageLocal ? .package(path: "../OSCAEssentials") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscaessentials-ios.git",
             .upToNextMinor(from: oscaEssentialsVersion)),
    /* OSCAPublicTransport */
    packageLocal ? .package(path: "../OSCAPublicTransport") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscapublictransport-ios.git",
             .upToNextMinor(from: oscaPublicTransportVersion)),
    /* SwiftSpinner */
    .package(url: "https://github.com/icanzilb/SwiftSpinner.git",
             .upToNextMinor(from: swiftSpinnerVersion)),
    // OSCATestCaseExtension
    packageLocal ? .package(path: "../OSCATestCaseExtension") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscatestcaseextension-ios.git",
             .upToNextMinor(from: oscaTestCaseExtensionVersion)),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "OSCAPublicTransportUI",
      dependencies: [/* OSCAEssentials */
                     .product(name: "OSCAEssentials",
                              package: packageLocal ? "OSCAEssentials" : "oscaessentials-ios"),
                     .product(name: "OSCAPublicTransport",
                              package: packageLocal ? "OSCAPublicTransport" : "oscapublictransport-ios"),
                     .product(name: "SwiftSpinner",
                              package: "SwiftSpinner")],
      path: "OSCAPublicTransportUI/OSCAPublicTransportUI",
      exclude:["Info.plist",
               "SupportingFiles"],
      resources: [.process("Resources")]
    ),
    .testTarget(
      name: "OSCAPublicTransportUITests",
      dependencies: ["OSCAPublicTransportUI",
                     .product(name: "OSCATestCaseExtension",
                              package: packageLocal ? "OSCATestCaseExtension" : "oscatestcaseextension-ios")],
      path: "OSCAPublicTransportUI/OSCAPublicTransportUITests",
      exclude: ["Info.plist"],
      resources: [.process("Resources")]
    ),
  ]
)
