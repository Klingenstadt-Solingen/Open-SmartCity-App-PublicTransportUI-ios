//
//  OSCAPublicTransportStopNearbyTableViewCell.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 10.05.22.
//

import OSCAEssentials
import UIKit

public final class OSCAPublicTransportStopNearbyTableViewCell: UITableViewCell {
  public static let identifier = String(describing: OSCAPublicTransportStopNearbyTableViewCell.self)
  
  @IBOutlet private var leftImageView: UIImageView!
  @IBOutlet private var titleStack: UIStackView!
  @IBOutlet private var titleLabel: UILabel!
  @IBOutlet private var detailLabel: UILabel!
  @IBOutlet private var timeLabel: UILabel!
  
  @IBOutlet private var leftImageViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet private var timeLabelTrailingContraint: NSLayoutConstraint!
  
  private var viewModel: OSCAPublicTransportStopNearbyCellViewModel!
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    self.tintColor = OSCAPublicTransportUI.configuration.colorConfig.primaryLight
    self.backgroundColor = OSCAPublicTransportUI.configuration.colorConfig.secondaryBackgroundColor
    let backgroundView = UIView()
    backgroundView.backgroundColor = OSCAPublicTransportUI.configuration.colorConfig.primaryColor.withAlphaComponent(0.5)
    self.selectedBackgroundView = backgroundView
    
    self.leftImageView.contentMode = .scaleAspectFit
    
    self.titleStack.distribution = .fillProportionally
    self.titleStack.spacing = 5
    
    self.titleLabel.font = OSCAPublicTransportUI.configuration.fontConfig.bodyHeavy
    self.titleLabel.textColor = OSCAPublicTransportUI.configuration.colorConfig.textColor
    self.titleLabel.adjustsFontSizeToFitWidth = false
    
    self.detailLabel.font = OSCAPublicTransportUI.configuration.fontConfig.smallLight
    self.detailLabel.textColor = OSCAPublicTransportUI.configuration.colorConfig.whiteColor.darker(componentDelta: 0.3)
    self.detailLabel.adjustsFontSizeToFitWidth = false
    
    self.timeLabel.adjustsFontSizeToFitWidth = false
    self.timeLabel.textAlignment = .right
    
    self.accessoryType = .detailDisclosureButton
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    if self.viewModel.row == (self.viewModel.publicTransportViewModel.numberOfItemsInSection - 1) {
      self.roundCorners(corners: [.bottomLeft, .bottomRight],
                        radius: OSCAPublicTransportUI.configuration.cornerRadius)
    } else {
      self.roundCorners(corners: .allCorners, radius: 0)
    }
  }
  
  public override func layoutIfNeeded() {
    super.layoutIfNeeded()
    self.leftImageViewHeightConstraint.constant = self.titleStack.frame.height
  }
  
  func fill(with viewModel: OSCAPublicTransportStopNearbyCellViewModel) {
    self.viewModel = viewModel
    
    self.titleLabel.text = viewModel.stop.name
    self.detailLabel.text = viewModel.lines
    
    if viewModel.lines.isEmpty {
      self.timeLabelTrailingContraint.constant = 16
      accessoryType = .none
    } else {
      self.timeLabelTrailingContraint.constant = 8
      accessoryType = .detailDisclosureButton
    }
    
    let attrTime = NSMutableAttributedString(
      string: viewModel.duration,
      attributes: [
        .font: OSCAPublicTransportUI.configuration.fontConfig.bodyHeavy,
        .foregroundColor: OSCAPublicTransportUI.configuration.colorConfig.textColor
      ]
    )
    let unit = NSAttributedString(
      string: " \(viewModel.publicTransportViewModel.minuteTitle)",
      attributes: [
        .font: OSCAPublicTransportUI.configuration.fontConfig.smallLight,
        .foregroundColor: OSCAPublicTransportUI.configuration.colorConfig.whiteColor.darker(componentDelta: 0.3)
      ]
    )
    attrTime.append(unit)
    self.timeLabel.attributedText = attrTime
    
    let image = UIImage(
      named: "stop",
      in: OSCAPublicTransportUI.bundle,
      with: .none)
    self.leftImageView.image = image
    
    viewModel.fill()
  }
}
