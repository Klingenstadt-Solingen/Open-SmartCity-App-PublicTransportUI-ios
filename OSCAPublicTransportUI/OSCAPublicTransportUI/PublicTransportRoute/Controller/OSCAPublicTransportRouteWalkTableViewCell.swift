//
//  OSCAPublicTransportRouteWalkTableViewCell.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 04.06.22.
//

import OSCAEssentials
import OSCAPublicTransport
import UIKit

public final class OSCAPublicTransportRouteWalkTableViewCell: UITableViewCell {
  static let reuseIdentifier = String(describing: OSCAPublicTransportRouteWalkTableViewCell.self)
  
  @IBOutlet private var leftImageView: UIImageView!
  @IBOutlet private var footpathLabel: UILabel!
  
  private var viewModel: OSCAPublicTransportRouteWalkCellViewModel!
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    self.backgroundColor = OSCAPublicTransportUI.configuration.colorConfig.secondaryBackgroundColor
    
    self.footpathLabel.font = OSCAPublicTransportUI.configuration.fontConfig.bodyLight
    self.footpathLabel.textColor = OSCAPublicTransportUI.configuration.colorConfig.textColor
    
    self.leftImageView.tintColor = OSCAPublicTransportUI.configuration.colorConfig.primaryColor
  }
  
  func fill(with viewModel: OSCAPublicTransportRouteWalkCellViewModel) {
    self.viewModel = viewModel
    
    let image: UIImage?
    if #available(iOS 14.0, *) {
      image = UIImage(systemName: "figure.walk")
    } else {
      image = UIImage(named: "figure.walk",
                      in: OSCAPublicTransportUI.bundle,
                      with: .none)
    }
    self.leftImageView.image = image?.withRenderingMode(.alwaysTemplate)
    self.footpathLabel.text = viewModel.footpathInfo
    
    viewModel.fill()
  }
}
