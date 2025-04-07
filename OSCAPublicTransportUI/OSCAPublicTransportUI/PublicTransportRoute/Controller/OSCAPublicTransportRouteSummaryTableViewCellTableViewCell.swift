//
//  OSCAPublicTransportRouteSummaryTableViewCellTableViewCell.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 03.06.22.
//

import OSCAEssentials
import OSCAPublicTransport
import UIKit

public final class OSCAPublicTransportRouteSummaryTableViewCellTableViewCell: UITableViewCell {
  static let reuseIdentifier = String(describing: OSCAPublicTransportRouteSummaryTableViewCellTableViewCell.self)
  
  @IBOutlet private var contentStack: UIStackView!
  @IBOutlet private var collectionView: UICollectionView!
  @IBOutlet private var durationLabel: UILabel!
  @IBOutlet private var startLabel: UILabel!
  @IBOutlet private var departureTimeLabel: UILabel!
  
  private var viewModel: OSCAPublicTransportRouteSummaryCellViewModel!
  
  var dataSource: UICollectionViewDiffableDataSource<OSCAPublicTransportRouteCellViewModel.Section, OSCAJourney.Trip>!
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    self.backgroundColor = OSCAPublicTransportUI.configuration.colorConfig.secondaryBackgroundColor
    
    self.contentStack.axis = .horizontal
    self.contentStack.alignment = .fill
    self.contentStack.distribution = .fill
    self.contentStack.spacing = 8
    
    self.collectionView.delegate = self
    self.collectionView.backgroundColor = .clear
    self.collectionView.showsVerticalScrollIndicator = false
    self.collectionView.showsHorizontalScrollIndicator = false
    
    self.durationLabel.font = OSCAPublicTransportUI.configuration.fontConfig.titleLight
    self.durationLabel.textColor = OSCAPublicTransportUI.configuration.colorConfig.whiteColor.darker(componentDelta: 0.3)
    self.durationLabel.textAlignment = .right
    
    self.startLabel.font = OSCAPublicTransportUI.configuration.fontConfig.bodyLight
    self.startLabel.textColor = OSCAPublicTransportUI.configuration.colorConfig.textColor
    
    self.departureTimeLabel.font = OSCAPublicTransportUI.configuration.fontConfig.bodyHeavy
    self.departureTimeLabel.textColor = OSCAPublicTransportUI.configuration.colorConfig.textColor
    self.departureTimeLabel.textAlignment = .right
  }
  
  func fill(with viewModel: OSCAPublicTransportRouteSummaryCellViewModel) {
    self.viewModel = viewModel
    
    self.updateCells(for: .lines)
    self.durationLabel.text = viewModel.journeyDuration
    self.departureTimeLabel.text = viewModel.departureTime
    self.startLabel.text = viewModel.departureInfo
    
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

extension OSCAPublicTransportRouteSummaryTableViewCellTableViewCell: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 10, height: 30)
  }
}
