//
//  OSCAPublicTransportDepartureTableViewCell.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 27.05.22.
//

import OSCAEssentials
import OSCAPublicTransport
import UIKit

public final class OSCAPublicTransportDepartureTableViewCell: UITableViewCell {
  public static let identifier = String(describing: OSCAPublicTransportDepartureTableViewCell.self)
  
  @IBOutlet private var contentStack: UIStackView!
  @IBOutlet private var timeStack: UIStackView!
  @IBOutlet private var departureTimeView: UIView!
  @IBOutlet private var departureTimeLabel: UILabel!
  @IBOutlet private var durationView: UIView!
  @IBOutlet private var durationLabel: UILabel!
  @IBOutlet private var lineView: UIView!
  @IBOutlet private var lineLabel: UILabel!
  @IBOutlet private var titleLabel: UILabel!
  
  private var viewModel: OSCAPublicTransportDepartureCellViewModel!
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    self.backgroundColor = .clear
    self.clipsToBounds = false
    self.contentView.backgroundColor = .clear
    self.contentView.clipsToBounds = false
    
    self.contentStack.axis = .vertical
    self.contentStack.distribution = .fillProportionally
    self.contentStack.spacing = 8
    self.contentStack.backgroundColor = OSCAPublicTransportUI.configuration.colorConfig.secondaryBackgroundColor
    self.contentStack.layer.borderColor = OSCAPublicTransportUI.configuration.colorConfig.accentColor.cgColor
    self.contentStack.layer.borderWidth = 1
    self.contentStack.layer.cornerRadius = OSCAPublicTransportUI.configuration.cornerRadius
    self.contentStack.addShadow(with: OSCAPublicTransportUI.configuration.shadow)
    
    self.timeStack.axis = .horizontal
    self.timeStack.alignment = .fill
    self.timeStack.distribution = .fillEqually
    self.timeStack.spacing = 8
    self.timeStack.backgroundColor = OSCAPublicTransportUI.configuration.colorConfig.accentColor
    
    self.lineView.backgroundColor = OSCAPublicTransportUI.configuration.colorConfig.secondaryBackgroundColor
    
    self.lineLabel.font = OSCAPublicTransportUI.configuration.fontConfig.bodyLight
    self.lineLabel.textColor = OSCAPublicTransportUI.configuration.colorConfig.textColor
    self.lineLabel.textAlignment = .center
    
    self.departureTimeView.backgroundColor = OSCAPublicTransportUI.configuration.colorConfig.secondaryBackgroundColor
    
    self.departureTimeLabel.font = OSCAPublicTransportUI.configuration.fontConfig.bodyLight
    self.departureTimeLabel.textColor = OSCAPublicTransportUI.configuration.colorConfig.textColor
    self.departureTimeLabel.textAlignment = .center
    
    self.durationView.backgroundColor = OSCAPublicTransportUI.configuration.colorConfig.secondaryBackgroundColor
    
    self.durationLabel.font = OSCAPublicTransportUI.configuration.fontConfig.bodyLight
    self.durationLabel.textColor = OSCAPublicTransportUI.configuration.colorConfig.textColor
    self.durationLabel.textAlignment = .center
    self.durationLabel.adjustsFontSizeToFitWidth = true
    
    self.titleLabel.font = OSCAPublicTransportUI.configuration.fontConfig.bodyHeavy
    self.titleLabel.textColor = OSCAPublicTransportUI.configuration.colorConfig.textColor
    self.titleLabel.textAlignment = .center
    self.titleLabel.numberOfLines = 2
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    self.timeStack.addLimitedCornerRadius(OSCAPublicTransportUI.configuration.cornerRadius)
    self.lineView.addLimitedCornerRadius(OSCAPublicTransportUI.configuration.cornerRadius)
    self.departureTimeView.addLimitedCornerRadius(OSCAPublicTransportUI.configuration.cornerRadius)
    self.durationView.addLimitedCornerRadius(OSCAPublicTransportUI.configuration.cornerRadius)
  }
  
  func fill(with viewModel: OSCAPublicTransportDepartureCellViewModel) {
    self.viewModel = viewModel
    
    let color = viewModel.vehicle.color
    let image = viewModel.vehicle.image
      .withTintColor(color)
    
    self.lineLabel.with(
      text: viewModel.departure.line ?? "",
      attachments: [image])
    
    self.departureTimeLabel.text = viewModel.departureTime
    self.durationLabel.text = viewModel.duration
    
    let destinationTitle = NSAttributedString(
      string: "\(viewModel.drivingDestinationTitle) ",
      attributes: [
        .font: OSCAPublicTransportUI.configuration.fontConfig.bodyLight,
        .foregroundColor: OSCAPublicTransportUI.configuration.colorConfig.whiteColor.darker(componentDelta: 0.3)])
    let destination = NSMutableAttributedString(attributedString: destinationTitle)
    destination.append(NSAttributedString(string: viewModel.drivingDestination))
    
    self.titleLabel.attributedText = destination
    
    viewModel.fill()
  }
}
