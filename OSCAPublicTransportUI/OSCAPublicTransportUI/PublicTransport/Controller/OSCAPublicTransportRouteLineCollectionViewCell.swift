//
//  OSCAPublicTransportRouteLineCollectionViewCell.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 01.06.22.
//

import OSCAEssentials
import UIKit

public final class OSCAPublicTransportRouteLineCollectionViewCell: UICollectionViewCell {
  public static let identifier = String(describing: OSCAPublicTransportRouteLineCollectionViewCell.self)
  
  @IBOutlet private var lineLabel: UILabel!
  
  private var viewModel: OSCAPublicTransportRouteLineCellViewModel!
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    self.contentView.addLimitedCornerRadius(OSCAPublicTransportUI.configuration.cornerRadius)
    
    self.lineLabel.font = OSCAPublicTransportUI.configuration.fontConfig.bodyLight
    self.lineLabel.textColor = OSCAPublicTransportUI.configuration.colorConfig.whiteDark
  }
  
  func fill(with viewModel: OSCAPublicTransportRouteLineCellViewModel) {
    self.viewModel = viewModel
    self.contentView.backgroundColor = viewModel.vehicle.color
    
    let color = OSCAPublicTransportUI.configuration
          .colorConfig.whiteDark
    let image = viewModel.vehicle.image
      .withTintColor(color)
    
    self.lineLabel.with(
      text: viewModel.line,
      attachments: [image])
    
    viewModel.fill()
  }
}
