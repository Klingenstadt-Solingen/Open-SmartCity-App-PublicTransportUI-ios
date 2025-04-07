//
//  OSCAPublicTransportDepartureViewController.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 18.05.22.
//  Reviewed by Stephan Breidenbach on 22.06.22
//

import OSCAEssentials
import OSCAPublicTransport
import UIKit

public final class OSCAPublicTransportDepartureViewController: UIViewController {
  
  @IBOutlet private var tableView: UITableView!
  
  private var viewModel: OSCAPublicTransportDepartureViewModel!
  
  var dataSource: UITableViewDiffableDataSource<OSCAPublicTransportDepartureViewModel.Section, OSCADeparturesForLocation.Stop.Departure>!
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    self.setupViews()
    self.setupBindings()
    self.viewModel.viewDidLoad()
  }
  
  private func setupViews() {
    self.navigationItem.title = self.viewModel.screenTitle
    
    self.view.backgroundColor = OSCAPublicTransportUI.configuration.colorConfig.backgroundColor
    
    self.tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
    self.tableView.allowsSelection = false
    self.tableView.separatorStyle = .none
    self.tableView.separatorInset = .zero
    self.tableView.separatorColor = OSCAPublicTransportUI.configuration.colorConfig.grayColor
    self.tableView.backgroundColor = .clear
    
    self.configureDataSource()
    self.updateCells()
    
    self.tableView.layoutIfNeeded()
  }
  
  private func setupBindings() {}
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setup(
      largeTitles: true,
      tintColor: OSCAPublicTransportUI.configuration.colorConfig.navigationTintColor,
      titleTextColor: OSCAPublicTransportUI.configuration.colorConfig.navigationTitleTextColor,
      barColor: OSCAPublicTransportUI.configuration.colorConfig.navigationBarColor)
  }
  
  private func configureDataSource() -> Void {
    self.dataSource = UITableViewDiffableDataSource(
      tableView: self.tableView,
      cellProvider: { (tableView, indexPath, departure) -> UITableViewCell in
        guard let cell = tableView.dequeueReusableCell(
          withIdentifier: OSCAPublicTransportDepartureTableViewCell.identifier,
          for: indexPath) as? OSCAPublicTransportDepartureTableViewCell
        else { return UITableViewCell() }
        
        let cellViewModel = OSCAPublicTransportDepartureCellViewModel(
          departure: departure)
        cell.fill(with: cellViewModel)
        
        return cell
      })
  }
  
  private func updateCells() {
    var snapshot = NSDiffableDataSourceSnapshot<OSCAPublicTransportDepartureViewModel.Section,OSCADeparturesForLocation.Stop.Departure>()
    snapshot.appendSections([.departures])
    snapshot.appendItems(self.viewModel.departures)
    self.dataSource.apply(snapshot, animatingDifferences: true)
  }
}

// MARK: - instantiate view conroller
extension OSCAPublicTransportDepartureViewController: StoryboardInstantiable {
  public static func create(with viewModel: OSCAPublicTransportDepartureViewModel) -> OSCAPublicTransportDepartureViewController {
    let vc = Self.instantiateViewController(OSCAPublicTransportUI.bundle)
    vc.viewModel = viewModel
    return vc
  }
}
