//
//  OSCAPublicTransportStopQueryTableViewCell.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 23.05.22.
//

import OSCAEssentials
import UIKit

public final class OSCAPublicTransportStopQueryTableViewCell: UITableViewCell {
  public static let identifier = String(describing: OSCAPublicTransportStopQueryTableViewCell.self)
  
  @IBOutlet private var leftImageView: UIImageView!
  @IBOutlet private var titleLabel: UILabel!
  
  private var viewModel: OSCAPublicTransportStopQueryCellViewModel!
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    self.backgroundColor = OSCAPublicTransportUI.configuration.colorConfig.secondaryBackgroundColor
    let backgroundView = UIView()
    backgroundView.backgroundColor = OSCAPublicTransportUI.configuration.colorConfig.primaryColor.withAlphaComponent(0.5)
    self.selectedBackgroundView = backgroundView
    
    self.leftImageView.contentMode = .scaleAspectFit
    
    self.titleLabel.font = OSCAPublicTransportUI.configuration.fontConfig.bodyHeavy
    self.titleLabel.textColor = OSCAPublicTransportUI.configuration.colorConfig.textColor
    self.titleLabel.adjustsFontSizeToFitWidth = false
    self.titleLabel.numberOfLines = 2
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    if viewModel.row == (self.viewModel.publicTransportViewModel.numberOfItemsInSection - 1) {
      self.roundCorners(corners: [.bottomLeft, .bottomRight],
                        radius: OSCAPublicTransportUI.configuration.cornerRadius)
    } else {
      self.roundCorners(corners: .allCorners, radius: 0)
    }
  }
  
  func fill(with viewModel: OSCAPublicTransportStopQueryCellViewModel) {
    self.viewModel = viewModel
    
    self.titleLabel.text = viewModel.stop.name
    
    let image = UIImage(
      named: "stop",
      in: OSCAPublicTransportUI.bundle,
      with: .none)
    self.leftImageView.image = image
    
    viewModel.fill()
  }
}
