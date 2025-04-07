//
//  OSCAPublicTransportVehicle.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 01.06.22.
//

import OSCAEssentials
import UIKit

public struct OSCAPublicTransportVehicle {
  public let type : Int
  public let image: UIImage
  public let color: UIColor
  
  public init(type: Int) {
    self.type = type
    
    switch type {
    case 0:
      image = UIImage(systemName: "exclamationmark.arrow.triangle.2.circlepath")
        ?? UIImage()
      color = OSCAPublicTransportUI.configuration
        .colorConfig.warningColor
      
    case 1, 13, 14, 15, 16, 17:
      image = UIImage(systemName: "train.side.front.car")
        ?? UIImage()
      color = UIColor(rgb: 0x007055)
      
    case 2:
      image = UIImage(systemName: "tram.fill.tunnel")
        ?? UIImage()
      color = UIColor(rgb: 0x003399)
      
    case 3, 4:
      image = UIImage(systemName: "tram.fill")
        ?? UIImage()
      color = UIColor(rgb: 0x003399)
      
    case 5, 6, 7:
      image = UIImage(systemName: "bus")
        ?? UIImage()
      color = UIColor(rgb: 0x00A0DD)
      
    case 8:
      image = UIImage(systemName: "cablecar")
        ?? UIImage()
      color = UIColor(rgb: 0x003399)
      
    case 99, 100:
      image = UIImage(systemName: "figure.walk")
        ?? UIImage()
      color = UIColor(rgb: 0x7A7A7A)
      
    default:
      image = UIImage()
      color = UIColor(rgb: 0x7A7A7A)
    }
  }
}
