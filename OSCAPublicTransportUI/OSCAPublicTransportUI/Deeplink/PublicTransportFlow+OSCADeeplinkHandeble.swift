//
//  PublicTransportFlow+OSCADeeplinkHandeble.swift
//  OSCAPublicTransportUI
//
//  Created by Stephan Breidenbach on 08.09.22.
//

import Foundation
import OSCAEssentials

extension OSCAPublicTransportFlowCoordinator: OSCADeeplinkHandeble {
  ///```console
  ///xcrun simctl openurl booted \
  /// "solingen://transport/route?from=20013800&to=20013771&dateTime=2022-09-09T18:39:49Z&arrDep=Arr"
  /// ```
  public func canOpenURL(_ url: URL) -> Bool {
    let deeplinkScheme: String = dependencies
      .deeplinkScheme
    return url.absoluteString.hasPrefix("\(deeplinkScheme)://transport")
  }// end public func canOpenURL
  
  public func openURL(_ url: URL,
                      onDismissed:(() -> Void)?) throws -> Void {
    guard canOpenURL(url)
    else { return }
    let deeplinkParser = DeeplinkParser()
    if let payload = deeplinkParser.parse(content: url) {
      switch payload.target {
      case "route":
        let from = payload.parameters["from"]
        let to = payload.parameters["to"]
        let dateTime = payload.parameters["datetime"]
        let arrDep = payload.parameters["arrdep"]
        showPublicTransportMainDeeplink(with: from,
                                      to,
                                      dateTime,
                                      arrDep,
                                onDismissed: onDismissed)
      default:
        showPublicTransportMain(animated: true,
                                onDismissed: onDismissed)
      }
    } else {
      showPublicTransportMain(animated: true,
                              onDismissed: onDismissed)
    }// end if
  }// end public func openURL
  
  /*public func showPublicTransportMain(with from: String? = nil,
                                      _ to: String? = nil,
                                      _ dateTime: String? = nil,
                                      _ arrDep: String? = nil,
                                      onDismissed:(() -> Void)?) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function): from: \(from ?? "NIL") to: \(to ?? "NIL") datetime: \(dateTime ?? "NIL") arrdep: \(arrDep ?? "NIL")")
#endif
  }// end func showPublicTransportMain*/
}// end extension final class OSCAPublicTransportFlowCoordinator
