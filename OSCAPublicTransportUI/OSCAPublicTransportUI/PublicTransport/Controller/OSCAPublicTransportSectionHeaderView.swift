//
//  OSCAPublicTransportSectionHeaderView.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 11.05.22.
//

import OSCAEssentials
import UIKit

public final class OSCAPublicTransportSectionHeaderView: UITableViewHeaderFooterView {
  public static let reuseIdentifier = String(describing: OSCAPublicTransportSectionHeaderView.self)
  
  @IBOutlet var titleLabel: UILabel!
  
  private var viewModel: OSCAPublicTransportSectionHeaderViewModel!
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    self.contentView.backgroundColor = OSCAPublicTransportUI.configuration.colorConfig.secondaryBackgroundColor
    
    self.titleLabel.font = OSCAPublicTransportUI.configuration.fontConfig.headlineLight
    self.titleLabel.textColor = OSCAPublicTransportUI.configuration.colorConfig.textColor
    self.titleLabel.adjustsFontSizeToFitWidth = false
    self.titleLabel.numberOfLines = 2
    self.titleLabel.textAlignment = .center
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    self.roundCorners(corners: [.topLeft, .topRight],
                      radius: OSCAPublicTransportUI.configuration.cornerRadius)
  }
  
  func fill(with viewModel: OSCAPublicTransportSectionHeaderViewModel) {
    self.viewModel = viewModel
    
    self.titleLabel.text = viewModel.title
    
    viewModel.fill()
  }
}
