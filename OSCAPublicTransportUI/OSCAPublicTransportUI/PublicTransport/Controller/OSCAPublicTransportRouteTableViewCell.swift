//
//  OSCAPublicTransportRouteTableViewCell.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 01.06.22.
//

import OSCAEssentials
import OSCAPublicTransport
import UIKit

public final class OSCAPublicTransportRouteTableViewCell: UITableViewCell {
  public static let identifier = String(describing: OSCAPublicTransportRouteTableViewCell.self)
  
  @IBOutlet private var contentStack: UIStackView!
  @IBOutlet private var durationLabel: UILabel!
  @IBOutlet private var collectionView: UICollectionView!
  @IBOutlet private var departureLabel: UILabel!
  
  private var viewModel: OSCAPublicTransportRouteCellViewModel!
  
  var dataSource: UICollectionViewDiffableDataSource<OSCAPublicTransportRouteCellViewModel.Section, OSCAJourney.Trip>!
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    self.tintColor = OSCAPublicTransportUI.configuration.colorConfig.primaryColor
    self.backgroundColor = OSCAPublicTransportUI.configuration.colorConfig.secondaryBackgroundColor
    let backgroundView = UIView()
    backgroundView.backgroundColor = OSCAPublicTransportUI.configuration.colorConfig.primaryColor.withAlphaComponent(0.5)
    self.selectedBackgroundView = backgroundView
    
    self.contentStack.axis = .vertical
    self.contentStack.alignment = .fill
    self.contentStack.distribution = .fill
    self.contentStack.spacing = 8
    
    self.durationLabel.font = OSCAPublicTransportUI.configuration.fontConfig.titleLight
    self.durationLabel.textColor = OSCAPublicTransportUI.configuration.colorConfig.whiteColor.darker(componentDelta: 0.3)
    
    self.collectionView.delegate = self
    self.collectionView.backgroundColor = .clear
    self.collectionView.showsVerticalScrollIndicator = false
    self.collectionView.showsHorizontalScrollIndicator = false
    
    self.departureLabel.font = OSCAPublicTransportUI.configuration.fontConfig.bodyLight
    self.departureLabel.textColor = OSCAPublicTransportUI.configuration.colorConfig.textColor
    self.departureLabel.numberOfLines = 0
    
    self.accessoryType = .disclosureIndicator
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    if viewModel.row == (viewModel.publicTransportViewModel.numberOfItemsInSection - 1) {
      self.roundCorners(corners: [.bottomLeft, .bottomRight],
                        radius: OSCAPublicTransportUI.configuration.cornerRadius)
    } else {
      self.roundCorners(corners: .allCorners, radius: 0)
    }
  }
  
  func fill(with viewModel: OSCAPublicTransportRouteCellViewModel) {
    self.viewModel = viewModel
    
    self.durationLabel.text = viewModel.journeyDuration
    self.updateCells(for: .lines)
    self.departureLabel.text = viewModel.departureInfo
    
    viewModel.fill()
  }
  
  private func configureDataSource(for section: OSCAPublicTransportRouteCellViewModel.Section) -> Void {
    self.dataSource = UICollectionViewDiffableDataSource(
      collectionView: self.collectionView,
      cellProvider: { (collectionView, indexPath, trip) -> UICollectionViewCell in
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: OSCAPublicTransportRouteLineCollectionViewCell.identifier,
          for: indexPath) as? OSCAPublicTransportRouteLineCollectionViewCell
        else { return UICollectionViewCell() }
        
        let cellViewModel = OSCAPublicTransportRouteLineCellViewModel(trip)
        cell.fill(with: cellViewModel)
        
        return cell
      })
  }
  
  private func updateCells(for section: OSCAPublicTransportRouteCellViewModel.Section) {
    self.configureDataSource(for: section)
    var snapshot = NSDiffableDataSourceSnapshot<OSCAPublicTransportRouteCellViewModel.Section,OSCAJourney.Trip>()
    
    snapshot.appendSections([section])
    if let trips = self.viewModel.journey.trips {
      snapshot.appendItems(trips)
    }
    
    self.dataSource.apply(snapshot, animatingDifferences: true)
  }
}

extension OSCAPublicTransportRouteTableViewCell: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 10, height: 30)
  }
}
