//
//  OSCAPublicTransportViewController.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 06.05.22.
//

import OSCAEssentials
import OSCAPublicTransport
import UIKit
import Combine
import SwiftSpinner
import SwiftDate

public final class OSCAPublicTransportViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var headerView: UIView!
    @IBOutlet private var routeView: UIView!
    @IBOutlet private var departureTextField: UITextField!
    @IBOutlet private var routeSeperatorView: UIView!
    @IBOutlet private var routeSwapButton: UIButton!
    @IBOutlet private var destinationTextField: UITextField!
    @IBOutlet private var travelTimeView: UIView!
    @IBOutlet private var travelSegmentedControl: UISegmentedControl!
    @IBOutlet private var travelTimeSeperatorView: UIView!
    @IBOutlet private var currentTimeButton: UIButton!
    @IBOutlet private var datePicker: UIDatePicker!
    @IBOutlet private var searchButton: UIButton!
    
    private var viewModel: OSCAPublicTransportViewModel!
    private var bindings = Set<AnyCancellable>()
    
    var dataSourceStop: UITableViewDiffableDataSource<OSCAPublicTransportViewModel.Section, OSCAStop>!
    var dataSourceRoute: UITableViewDiffableDataSource<OSCAPublicTransportViewModel.Section, OSCAJourney>!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBindings()
        viewModel.viewDidLoad()
    }
    
    private var activeField: UITextField?
    
    private func setupViews() {
        self.tableView.delegate = self
        
        self.navigationItem.title = viewModel.screenTitle
        
        self.view.backgroundColor = OSCAPublicTransportUI.configuration.colorConfig.backgroundColor
        
        tableView.canCancelContentTouches = true
        tableView.delaysContentTouches = true
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.keyboardDismissMode = .interactive
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        tableView.separatorColor = OSCAPublicTransportUI.configuration.colorConfig.grayColor
        tableView.backgroundColor = .clear
        tableView.register(
            UINib(nibName: OSCAPublicTransportSectionHeaderView.reuseIdentifier,
                  bundle: OSCAPublicTransportUI.bundle),
            forHeaderFooterViewReuseIdentifier: OSCAPublicTransportSectionHeaderView.reuseIdentifier)
        tableView.addShadow(with: OSCAPublicTransportUI.configuration.shadow)
        
        headerView.backgroundColor = .clear
        
        routeView.backgroundColor = OSCAPublicTransportUI.configuration.colorConfig.secondaryBackgroundColor
        routeView.addLimitedCornerRadius(OSCAPublicTransportUI.configuration.cornerRadius)
        routeView.addShadow(with: OSCAPublicTransportUI.configuration.shadow)
        
        routeSeperatorView.backgroundColor = OSCAPublicTransportUI.configuration.colorConfig.grayDarker
        routeSeperatorView.layer.cornerRadius = routeSeperatorView.frame.height / 2
        
        departureTextField.font = OSCAPublicTransportUI.configuration.fontConfig.subheaderLight
        departureTextField.placeholder = viewModel.departurePlaceholder
        departureTextField.textColor = OSCAPublicTransportUI.configuration.colorConfig.textColor
        departureTextField.tintColor = OSCAPublicTransportUI.configuration.colorConfig.primaryColor
        departureTextField.borderStyle = .none
        departureTextField.adjustsFontSizeToFitWidth = true
        departureTextField.minimumFontSize = 20
        departureTextField.clearButtonMode = .whileEditing
        departureTextField.inputAccessoryView = keyboardToolbar()
        
        routeSwapButton.setTitle("", for: .normal)
        let imageConfig = UIImage.SymbolConfiguration(scale: .large)
        let imageFill = UIImage(systemName: "arrow.up.arrow.down.circle")?
            .withConfiguration(imageConfig)
        let image = UIImage(systemName: "arrow.up.arrow.down.circle.fill")?
            .withConfiguration(imageConfig)
        routeSwapButton.setImage(imageFill, for: .normal)
        routeSwapButton.setImage(image, for: .highlighted)
        routeSwapButton.imageView?.contentMode = .scaleAspectFit
        routeSwapButton.contentHorizontalAlignment = .fill
        routeSwapButton.contentVerticalAlignment = .fill
        routeSwapButton.layer.cornerRadius = routeSwapButton.frame.height / 2
        routeSwapButton.tintColor = OSCAPublicTransportUI.configuration.colorConfig.primaryColor
        routeSwapButton.backgroundColor = OSCAPublicTransportUI.configuration.colorConfig.secondaryBackgroundColor
        
        destinationTextField.font = OSCAPublicTransportUI.configuration.fontConfig.subheaderLight
        destinationTextField.placeholder = viewModel.destinationPlaceholder
        destinationTextField.textColor = OSCAPublicTransportUI.configuration.colorConfig.textColor
        destinationTextField.tintColor = OSCAPublicTransportUI.configuration.colorConfig.primaryColor
        destinationTextField.borderStyle = .none
        destinationTextField.adjustsFontSizeToFitWidth = true
        destinationTextField.minimumFontSize = 20
        destinationTextField.clearButtonMode = .whileEditing
        destinationTextField.inputAccessoryView = keyboardToolbar()
        
        travelTimeView.backgroundColor = OSCAPublicTransportUI.configuration.colorConfig.secondaryBackgroundColor
        travelTimeView.addLimitedCornerRadius(OSCAPublicTransportUI.configuration.cornerRadius)
        travelTimeView.addShadow(with: OSCAPublicTransportUI.configuration.shadow)
        
        travelSegmentedControl.setTitle(viewModel.departureTitle, forSegmentAt: 0)
        travelSegmentedControl.setTitle(viewModel.arrivalTitle, forSegmentAt: 1)
        let travelTextAttributes: [NSAttributedString.Key: Any] = [
            .font: OSCAPublicTransportUI.configuration.fontConfig.bodyLight,
            .foregroundColor: OSCAPublicTransportUI.configuration.colorConfig.textColor,
        ]
        travelSegmentedControl.setTitleTextAttributes(
            travelTextAttributes,
            for: .normal)
        travelSegmentedControl.selectedSegmentIndex = viewModel.tripType == .departure ? 0 : 1
        
        travelTimeSeperatorView.backgroundColor = OSCAPublicTransportUI.configuration.colorConfig.grayDarker
        travelTimeSeperatorView.layer.cornerRadius = travelTimeSeperatorView.frame.height / 2
        
        currentTimeButton.setTitle(viewModel.currentTimeTitle, for: .normal)
        currentTimeButton.setTitleColor(
            OSCAPublicTransportUI.configuration.colorConfig.primaryColor,
            for: .normal)
        currentTimeButton.titleLabel?.font = OSCAPublicTransportUI.configuration.fontConfig.subheaderHeavy
        
        datePicker.datePickerMode = .dateAndTime
        datePicker.timeZone = .current
        datePicker.contentHorizontalAlignment = .trailing
        datePicker.tintColor = OSCAPublicTransportUI.configuration.colorConfig.primaryColor
        datePicker.setDate(viewModel.tripDate.toISODate()?.date ?? Date(), animated: true)
        
        
        self.searchButton.setTitle(self.viewModel.searchTitle, for: .normal)
        
        self.searchButton.setTitleColor(
            OSCAPublicTransportUI.configuration.colorConfig.whiteColor,
            for: .normal)
        self.searchButton.setTitleColor(
            OSCAPublicTransportUI.configuration.colorConfig.blackColor.lighter(componentDelta: 0.6),
            for: .disabled)
        
        self.searchButton.titleLabel?.font = OSCAPublicTransportUI.configuration.fontConfig.subheaderHeavy
        let imageSearch = UIImage(systemName: "magnifyingglass")
        imageSearch?.withRenderingMode(.alwaysTemplate)
        self.searchButton.setImage(imageSearch, for: .normal)
        self.searchButton.tintColor = OSCAPublicTransportUI.configuration.colorConfig.whiteColor
        self.searchButton.semanticContentAttribute = .forceLeftToRight
        self.searchButton.addLimitedCornerRadius(OSCAPublicTransportUI.configuration.cornerRadius)
        self.searchButton.addShadow(with: OSCAPublicTransportUI.configuration.shadow)
        
        self.verifySearchButton()
        
        // This has to be at the end, so that the size of all views are correct
        if let headerView = tableView.tableHeaderView {
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            tableView.tableHeaderView?.frame.size.height = height
        }
        
        //self.departureTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        //self.destinationTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        self.departureTextField.isEnabled = true
        let showOriginStationSearchGesture = UITapGestureRecognizer(target: self, action: #selector(showOriginSelect))
        self.departureTextField.isUserInteractionEnabled = true
        self.departureTextField.addGestureRecognizer(showOriginStationSearchGesture)
        
        self.destinationTextField.isEnabled = true
        
        let showDestinationStationSearchGesture = UITapGestureRecognizer(target: self, action: #selector(showDestinationSelect))
        self.destinationTextField.isUserInteractionEnabled = true
        self.destinationTextField.addGestureRecognizer(showDestinationStationSearchGesture)
        
        if(self.viewModel.selectedDepartureId != nil && self.viewModel.selectedDestinationId != nil){
            // suche nach der Route
            SwiftSpinner.show(self.viewModel.swiftSpinnerTitle, animated: true)
            viewModel.searchButtonTouch()
            view.endEditing(true)
        }
        //tableView.isHidden = self.viewModel.state != .finishedLoadingRoute
    }
    
    @objc func showOriginSelect() {
        self.viewModel.openStationSearch(for: .departure)
    }
    
    @objc func showDestinationSelect() {
        self.viewModel.openStationSearch(for: .destination)
    }
    
    private func verifySearchButton() {
        let colorConfig = OSCAPublicTransportUI.configuration.colorConfig
        
        let canSearch = viewModel.selectedDepartureId != nil && viewModel.selectedDestinationId != nil && !(self.departureTextField.text?.isEmpty ?? true) && !(self.destinationTextField.text?.isEmpty ?? true)
        
        self.searchButton.backgroundColor = canSearch ? colorConfig.primaryColor : colorConfig.grayColor
        self.searchButton.tintColor = canSearch ? colorConfig.whiteColor : colorConfig.blackLight
        self.searchButton.isEnabled = canSearch
    }
    
    private func setupBindings() {
        viewModel.$departureText
            .receive(on: RunLoop.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] departureText in
                guard let `self` = self else { return }
                self.departureTextField.text = departureText
                self.scrollToTop()
                self.verifySearchButton()
            })
            .store(in: &bindings)
        
        viewModel.$destinationText
            .receive(on: RunLoop.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] destinationText in
                guard let `self` = self else { return }
                self.destinationTextField.text = destinationText
                self.scrollToTop()
                self.verifySearchButton()
            })
            .store(in: &bindings)
        
        let stateValueHandler: (OSCAPublicTransportViewModelState) -> Void = { [weak self] state in
            guard let `self` = self else { return }
            
            switch state {
            case .loadingNearby:
                self.updateHeader(for: .nearby)
                break
            case .loadingQuery:
                self.updateHeader(for: .query)
                
            case .loadingRoute:
                SwiftSpinner.show(self.viewModel.swiftSpinnerTitle, animated: true)
                
            case .finishedLoadingNearby:
                self.updateCells(for: .nearby)
                
            case .finishedLoadingQuery:
                self.updateCells(for: .query)
                
            case .finishedLoadingRoute:
                self.updateCells(for: .routes)
                SwiftSpinner.hide()
                
            case .error(_):
                SwiftSpinner.hide()
                
            case .waitingForQuery:
                SwiftSpinner.hide()
            }
            
            //tableView.isHidden = state != .finishedLoadingRoute
        }
        
        viewModel.$state
            .receive(on: RunLoop.main)
            .dropFirst()
            .sink(receiveValue: stateValueHandler)
            .store(in: &bindings)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setup(
            largeTitles: true,
            tintColor: OSCAPublicTransportUI.configuration.colorConfig.navigationTintColor,
            titleTextColor: OSCAPublicTransportUI.configuration.colorConfig.navigationTitleTextColor,
            barColor: OSCAPublicTransportUI.configuration.colorConfig.navigationBarColor)
        registerForKeyboardNotifications()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterFromKeyboardNotifications()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.viewDidAppear()
    }
    
    private func configureDataSource(for section: OSCAPublicTransportViewModel.Section) -> Void {
        switch section {
        case .nearby:
            dataSourceStop = UITableViewDiffableDataSource(
                tableView: tableView,
                cellProvider: { tableView, indexPath, stop -> UITableViewCell in
                    guard let cell = tableView.dequeueReusableCell(
                        withIdentifier: OSCAPublicTransportStopNearbyTableViewCell.identifier,
                        for: indexPath) as? OSCAPublicTransportStopNearbyTableViewCell
                    else { return UITableViewCell() }
                    
                    let cellViewModel = OSCAPublicTransportStopNearbyCellViewModel(
                        viewModel: self.viewModel,
                        stop: stop,
                        at: indexPath.row)
                    cell.fill(with: cellViewModel)
                    
                    return cell
                })
            
        case .query:
            dataSourceStop = UITableViewDiffableDataSource(
                tableView: tableView,
                cellProvider: { tableView, indexPath, stop -> UITableViewCell in
                    guard let cell = tableView.dequeueReusableCell(
                        withIdentifier: OSCAPublicTransportStopQueryTableViewCell.identifier,
                        for: indexPath) as? OSCAPublicTransportStopQueryTableViewCell
                    else { return UITableViewCell() }
                    
                    let cellViewModel = OSCAPublicTransportStopQueryCellViewModel(
                        viewModel: self.viewModel,
                        stop: stop,
                        at: indexPath.row)
                    cell.fill(with: cellViewModel)
                    
                    return cell
                })
            
        case .routes:
            dataSourceRoute = UITableViewDiffableDataSource(
                tableView: tableView,
                cellProvider: { tableView, indexPath, journey -> UITableViewCell in
                    guard let cell = tableView.dequeueReusableCell(
                        withIdentifier: OSCAPublicTransportRouteTableViewCell.identifier,
                        for: indexPath) as? OSCAPublicTransportRouteTableViewCell
                    else { return UITableViewCell() }
                    
                    let cellViewModel = OSCAPublicTransportRouteCellViewModel(
                        viewModel: self.viewModel,
                        journey: journey,
                        at: indexPath.row)
                    cell.fill(with: cellViewModel)
                    
                    return cell
                })
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        verifySearchButton()
    }
    
    private func updateCells(for section: OSCAPublicTransportViewModel.Section) {
        self.configureDataSource(for: section)
        
        switch section {
        case .nearby, .query:
            let stops = section == .nearby
            ? viewModel.stopsNearby
            : viewModel.stopsQueried
            
            var snapshot = NSDiffableDataSourceSnapshot<OSCAPublicTransportViewModel.Section,OSCAStop>()
            
            snapshot.appendSections([section])
            snapshot.appendItems(stops, toSection: section)
            
            dataSourceStop.apply(snapshot, animatingDifferences: true)
            
        case .routes:
            var snapshot = NSDiffableDataSourceSnapshot<OSCAPublicTransportViewModel.Section,OSCAJourney>()
            
            snapshot.appendSections([section])
            snapshot.appendItems(viewModel.journeys, toSection: section)
            
            dataSourceRoute.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func updateHeader(for section: OSCAPublicTransportViewModel.Section) {
        guard let header = tableView.headerView(forSection: 0) as? OSCAPublicTransportSectionHeaderView
        else { return }
        switch section {
        case .nearby:
            header.titleLabel.text = viewModel.nearbyStopsLoadingTitle
            
        case .query:
            header.titleLabel.text = viewModel.queriedStopsLoadingTitle
            
        case .routes: break
        }
    }
    
    private func scrollToTop() {
        self.tableView.setContentOffset(.zero, animated: true)
    }
    
    private func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillAppear(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillDisappear(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    private func deregisterFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    private func keyboardToolbar() -> UIToolbar {
        let keyboardToolbar = UIToolbar()
        let flexibleSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil)
        let myLocationButton = UIBarButtonItem(
            title: viewModel.myLocationTitle,
            style: .plain,
            target: self,
            action: #selector(keyboardMyLocationButtonTouch(barButton:)))
        myLocationButton.tintColor = OSCAPublicTransportUI.configuration.colorConfig.primaryColor
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(keyboardDoneButtonTouch(barButton:)))
        doneButton.tintColor = OSCAPublicTransportUI.configuration.colorConfig.primaryColor
        keyboardToolbar.items = [flexibleSpace,myLocationButton, flexibleSpace, doneButton]
        keyboardToolbar.sizeToFit()
        keyboardToolbar.layoutIfNeeded()
        return keyboardToolbar
    }
    
    @objc private func keyboardMyLocationButtonTouch(barButton: UIBarButtonItem) {
        viewModel.keyboardMyLocationButtonTouch()
    }
    
    @objc private func keyboardDoneButtonTouch(barButton: UIBarButtonItem) {
        self.view.endEditing(true)
    }
    
    @objc private func keyboardWillAppear(notification: NSNotification) {
        self.tableView.isScrollEnabled = true
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
        var adjustedHeight = keyboardSize!.height
        if let tabbarSize = tabBarController?.tabBar.frame.size {
            adjustedHeight = keyboardSize!.height - tabbarSize.height
        }
        
        let contentInsets = UIEdgeInsets(top: 0.0,
                                         left: 0.0,
                                         bottom: adjustedHeight,
                                         right: 0.0)
        
        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets
        
        var aRect: CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)) {
                self.tableView.scrollRectToVisible(activeField.frame,
                                                   animated: true)
            }
        }
    }
    
    @objc private func keyboardWillDisappear(notification: NSNotification) {
        let contentInsets: UIEdgeInsets = .zero
        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets
    }
    
    @IBAction private func searchFieldEditingDidBegin(_ sender: UITextField) {
        switch sender {
        case departureTextField:
            viewModel.focusedSearchField = .departure
            
        case destinationTextField:
            viewModel.focusedSearchField = .destination
            
        default: break
        }
    }
    
    @IBAction private func searchFieldEditingChanged(_ sender: UITextField) {
        guard let text = sender.text else { return }
        viewModel.searchFieldEditingChanged(with: text)
        verifySearchButton()
    }
    
    @IBAction private func routeSwapButtonTouch(_ sender: UIButton) {
        guard let departure = departureTextField.text,
              let destination = destinationTextField.text
        else { return }
        viewModel.routeSwapButtonTouch(departure, destination)
    }
    
    @IBAction func travelSegmentedControlTouch(_ sender: UISegmentedControl) {
        viewModel.travelSegmentedControlTouch(index: sender.selectedSegmentIndex)
    }
    
    @IBAction func currentTimeButtonTouch(_ sender: UIButton) {
        datePicker.setDate(Date(), animated: true)
        viewModel.currentTimeButtonTouch(datePicker.date)
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        viewModel.datePickerValueChanged(sender.date)
    }
    
    @IBAction private func searchButtonTouch(_ sender: UIButton) {
        viewModel.searchButtonTouch()
        view.endEditing(true)
    }
}

// MARK: - instantiate view conroller
extension OSCAPublicTransportViewController: StoryboardInstantiable {
    public static func create(with viewModel: OSCAPublicTransportViewModel) -> OSCAPublicTransportViewController {
        let vc = Self.instantiateViewController(OSCAPublicTransportUI.bundle)
        vc.viewModel = viewModel
        return vc
    }
}

extension OSCAPublicTransportViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch viewModel.visibleSection {
        case .routes: return 70
        default: return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch viewModel.visibleSection {
        case .query: return 50
        case nil: return 0
        default: return UITableView.automaticDimension
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: OSCAPublicTransportSectionHeaderView.reuseIdentifier) as? OSCAPublicTransportSectionHeaderView
        else { return UIView() }
        
        let headerViewModel = OSCAPublicTransportSectionHeaderViewModel(
            viewModel: self.viewModel)
        header.fill(with: headerViewModel)
        
        return header
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectRow(at: indexPath.row)
        view.endEditing(true)
    }
    
    public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        viewModel.accessoryButtonTapped(for: indexPath.row)
    }
}
