//
//  OSCAPublicTransportRouteTripTableViewCell.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 04.06.22.
//

import OSCAEssentials
import OSCAPublicTransport
import UIKit

public final class OSCAPublicTransportRouteTripTableViewCell: UITableViewCell {
  static let reuseIdentifier = String(describing: OSCAPublicTransportRouteTripTableViewCell.self)
  
  @IBOutlet private var fromImageView: UIImageView!
  @IBOutlet private var toImageView: UIImageView!
  @IBOutlet private var fromStopLabel: UILabel!
  @IBOutlet private var toStopLabel: UILabel!
  @IBOutlet private var fromTimeLabel: UILabel!
  @IBOutlet private var toTimeLabel: UILabel!
  @IBOutlet private var fromToLineView: UIView!
  @IBOutlet private var lineLabel: UILabel!
  @IBOutlet private var destinationStack: UIStackView!
  @IBOutlet private var destinationImageView: UIImageView!
  @IBOutlet private var lineDestinationLabel: UILabel!
  @IBOutlet private var stopsCountLabel: UILabel!
  @IBOutlet private var durationLabel: UILabel!
  
  private var viewModel: OSCAPublicTransportRouteTripCellViewModel!
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    self.backgroundColor = OSCAPublicTransportUI.configuration.colorConfig.secondaryBackgroundColor
    
    self.fromStopLabel.font = OSCAPublicTransportUI.configuration.fontConfig.bodyLight
    self.fromStopLabel.textColor = OSCAPublicTransportUI.configuration.colorConfig.textColor
    
    self.toStopLabel.font = OSCAPublicTransportUI.configuration.fontConfig.bodyLight
    self.toStopLabel.textColor = OSCAPublicTransportUI.configuration.colorConfig.textColor
    
    self.fromTimeLabel.font = OSCAPublicTransportUI.configuration.fontConfig.captionLight
    self.fromTimeLabel.textColor = OSCAPublicTransportUI.configuration.colorConfig.whiteColor.darker(componentDelta: 0.3)
    
    self.toTimeLabel.font = OSCAPublicTransportUI.configuration.fontConfig.captionLight
    self.toTimeLabel.textColor = OSCAPublicTransportUI.configuration.colorConfig.whiteColor.darker(componentDelta: 0.3)
    
    self.fromToLineView.backgroundColor = OSCAPublicTransportUI.configuration.colorConfig.primaryColor
    
    self.destinationStack.axis = .vertical
    self.destinationStack.alignment = .fill
    self.destinationStack.distribution = .fillProportionally
    self.destinationStack.spacing = 8
    
    self.lineLabel.font = OSCAPublicTransportUI.configuration.fontConfig.captionLight
    self.lineLabel.textColor = OSCAPublicTransportUI.configuration.colorConfig.whiteColor.darker(componentDelta: 0.3)
    
    self.destinationImageView.contentMode = .scaleAspectFit
    self.destinationImageView.tintColor = OSCAPublicTransportUI.configuration.colorConfig.whiteColor.darker(componentDelta: 0.3)
    
    self.lineDestinationLabel.font = OSCAPublicTransportUI.configuration.fontConfig.captionLight
    self.lineDestinationLabel.textColor = OSCAPublicTransportUI.configuration.colorConfig.whiteColor.darker(componentDelta: 0.3)
    self.lineDestinationLabel.numberOfLines = 0
    
    self.stopsCountLabel.font = OSCAPublicTransportUI.configuration.fontConfig.captionLight
    self.stopsCountLabel.textColor = OSCAPublicTransportUI.configuration.colorConfig.primaryColor
    
    self.durationLabel.font = OSCAPublicTransportUI.configuration.fontConfig.bodyLight
    self.durationLabel.textColor = OSCAPublicTransportUI.configuration.colorConfig.textColor
  }
  
  func fill(with viewModel: OSCAPublicTransportRouteTripCellViewModel) {
    self.viewModel = viewModel
    
    self.fromImageView.image = UIImage(named: "stop",
                                       in: OSCAPublicTransportUI.bundle,
                                       with: .none)
    self.toImageView.image = UIImage(named: "stop",
                                     in: OSCAPublicTransportUI.bundle,
                                     with: .none)
    let image = UIImage(systemName: "arrow.right")
    image?.withRenderingMode(.alwaysTemplate)
    self.destinationImageView.image = image
    
    self.fromStopLabel.text = viewModel.trip.origin?.name ?? ""
    self.toStopLabel.text = viewModel.trip.destination?.name ?? ""
    
    let color = OSCAPublicTransportUI.configuration
      .colorConfig.whiteColor.darker(componentDelta: 0.3)
    let vehicleImage = viewModel.vehicle.image
      .withTintColor(color)
    
    self.lineLabel.with(
      text: viewModel.line,
      attachments: [vehicleImage])
    
    self.lineDestinationLabel.text = viewModel.trip.transportation?.destination?.name ?? ""
    
    self.durationLabel.text = viewModel.duration
    
    self.fromTimeLabel.text = viewModel.departureTime
    self.toTimeLabel.text = viewModel.destinationTime
    
    self.stopsCountLabel.text = viewModel.countOfStops
    
    
    viewModel.fill()
  }
}
