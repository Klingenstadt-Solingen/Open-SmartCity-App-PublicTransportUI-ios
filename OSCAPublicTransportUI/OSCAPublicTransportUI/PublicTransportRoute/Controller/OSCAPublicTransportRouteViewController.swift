//
//  OSCAPublicTransportRouteViewController.swift
//  OSCAPublicTransportUI
//
//  Created by Ömer Kurutay on 03.06.22.
//  Reviewed by Stephan Breidenbach on 22.96.22
//

import OSCAEssentials
import OSCAPublicTransport
import UIKit
import MapKit

public final class OSCAPublicTransportRouteViewController: UIViewController {
  
  @IBOutlet private var mapContainer: UIView!
  @IBOutlet private var mapView: MKMapView!
  @IBOutlet private var tableView: UITableView!
  @IBOutlet private var mapViewHeight: NSLayoutConstraint!
  
  private var viewModel: OSCAPublicTransportRouteViewModel!
  
  /// The original heigt of the headerContainer
  var originalHeight: CGFloat!
  /// Maximum height for the headerContainer
  var headerViewMaxHeight: CGFloat = 0
  /// Minimum height for the headerContainer
  var headerViewMinHeight: CGFloat = 0
  var routeLine: MKPolyline?
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    self.setupViews()
    self.setupBindings()
    self.viewModel.viewDidLoad()
  }
  
  private func setupViews() {
    self.navigationItem.title = self.viewModel.screenTitle
    
    self.view.backgroundColor = OSCAPublicTransportUI.configuration.colorConfig.backgroundColor
    
    self.mapView.delegate = self
    self.mapView.register(MKMarkerAnnotationView.self,
                          forAnnotationViewWithReuseIdentifier: "Annotation")
    self.mapView.layer.cornerRadius = OSCAPublicTransportUI.configuration.cornerRadius
    self.mapContainer.layer.cornerRadius = OSCAPublicTransportUI.configuration.cornerRadius
    self.mapContainer.addShadow(with: OSCAPublicTransportUI.configuration.shadow)
    
    self.tableView.allowsSelection = false
    self.tableView.backgroundColor = .clear
    self.tableView.addShadow(with: OSCAPublicTransportUI.configuration.shadow)
  }
  
  private func setupBindings() {}
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.mapViewHeight.constant = 250
    self.originalHeight = self.mapViewHeight.constant
    self.headerViewMaxHeight = originalHeight
    self.headerViewMinHeight = 100
    
    self.navigationController?.setup(
      tintColor: OSCAPublicTransportUI.configuration.colorConfig.navigationTintColor,
      titleTextColor: OSCAPublicTransportUI.configuration.colorConfig.navigationTitleTextColor,
      barColor: OSCAPublicTransportUI.configuration.colorConfig.navigationBarColor)
  }
  
  public override func viewDidLayoutSubviews() {
    var locations: [CLLocationCoordinate2D] = []
    guard let trips = self.viewModel.journey.trips else { return }
    
    for (index, trip) in trips.enumerated() {
      var coords: [CLLocationCoordinate2D] = []
      guard let paths = trip.coords else { return }
      
      for path in paths {
        let location = CLLocationCoordinate2D(latitude: path[0], longitude: path[1])
        locations.append(location)
        coords.append(location)
      }
      let overlay = MKPolyline(coordinates: coords, count: coords.count)
      overlay.title = "\(index)"
      self.mapView.addOverlay(overlay)
      
      guard let start = paths.first,
            let end = paths.last else { continue }
      
      let startAnnotation = OSCAMapAnnotation()
      let endAnnotation = OSCAMapAnnotation()
      startAnnotation.coordinate = CLLocationCoordinate2D(latitude: start[0], longitude: start[1])
      endAnnotation.coordinate = CLLocationCoordinate2D(latitude: end[0], longitude: end[1])
      
      self.mapView.addAnnotations([startAnnotation, endAnnotation])
    }
    
    self.routeLine = MKPolyline(coordinates: locations, count: locations.count)
    if let routeLine = routeLine {
      self.mapView.addOverlay(routeLine)
      self.mapView.setVisibleMapRect(routeLine.boundingMapRect, animated: true)
      
      let routeRegion = MKCoordinateRegion(routeLine.boundingMapRect)
      let latDelta = routeRegion.span.latitudeDelta
      let lonDelta = routeRegion.span.longitudeDelta
      let center = routeRegion.center
      let span = MKCoordinateSpan(latitudeDelta: latDelta * 2, longitudeDelta: lonDelta * 2)
      let region = MKCoordinateRegion(center: center, span: span)
      
      self.mapView.setRegion(region, animated: true)
    }
  }
}

// MARK: - instantiate view conroller
extension OSCAPublicTransportRouteViewController: StoryboardInstantiable {
  public static func create(with viewModel: OSCAPublicTransportRouteViewModel) -> OSCAPublicTransportRouteViewController {
    let vc = Self.instantiateViewController(OSCAPublicTransportUI.bundle)
    vc.viewModel = viewModel
    return vc
  }
}

extension OSCAPublicTransportRouteViewController: UITableViewDelegate, UITableViewDataSource {
  public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    self.viewModel.numberOfRowsInSection
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == 0 {
      guard let cell = tableView.dequeueReusableCell(
        withIdentifier: OSCAPublicTransportRouteSummaryTableViewCellTableViewCell.reuseIdentifier,
        for: indexPath) as? OSCAPublicTransportRouteSummaryTableViewCellTableViewCell
      else { return UITableViewCell() }
      
      let cellViewModel = OSCAPublicTransportRouteSummaryCellViewModel(
        journey: self.viewModel.journey)
      cell.fill(with: cellViewModel)
      
      return cell
      
    } else {
      guard let trip = self.viewModel.journey.trips?[indexPath.row - 1] else { return UITableViewCell() }
      
      if let typeOfTransport = trip.transportation?.product?.klazz,
         typeOfTransport == 100 || typeOfTransport == 99
      {
        guard let cell = tableView.dequeueReusableCell(
          withIdentifier: OSCAPublicTransportRouteWalkTableViewCell.reuseIdentifier,
          for: indexPath) as? OSCAPublicTransportRouteWalkTableViewCell
        else { return UITableViewCell() }
        
        let cellViewModel = OSCAPublicTransportRouteWalkCellViewModel(trip: trip)
        cell.fill(with: cellViewModel)
        
        return cell
        
      } else {
        guard let cell = tableView.dequeueReusableCell(
          withIdentifier: OSCAPublicTransportRouteTripTableViewCell.reuseIdentifier,
          for: indexPath) as? OSCAPublicTransportRouteTripTableViewCell
        else { return UITableViewCell() }
        
        let cellViewModel = OSCAPublicTransportRouteTripCellViewModel(trip: trip)
        cell.fill(with: cellViewModel)

        return cell
      }
    }
  }
  
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let offset = scrollView.contentOffset.y
    let newHeaderViewHeight: CGFloat = self.mapViewHeight.constant - offset
    
    if newHeaderViewHeight > self.headerViewMaxHeight {
      self.mapViewHeight.constant = self.headerViewMaxHeight
    } else if newHeaderViewHeight < self.headerViewMinHeight {
      self.mapViewHeight.constant = self.headerViewMinHeight
    } else {
      self.mapViewHeight.constant = newHeaderViewHeight
      scrollView.contentOffset.y = 0 // block scroll view
    }
  }
}

extension OSCAPublicTransportRouteViewController: MKMapViewDelegate {
  public func mapView(_: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if overlay is MKPolyline {
      let lineView = MKPolylineRenderer(overlay: overlay)
      guard let title = overlay.title ?? nil,
            let pos = Int(title),
            let type = self.viewModel.journey.trips?[pos].transportation?.product?.klazz
      else { return MKOverlayRenderer() }
      let vehicle = OSCAPublicTransportVehicle(type: type)
      lineView.strokeColor = vehicle.color
      lineView.lineWidth = 5.0
      return lineView
    }
    return MKOverlayRenderer()
  }
  
  /// Returns the view associated with the specified annotation object.
  /// - Parameters:
  ///   - mapView: The map view that requested the annotation view.
  ///   - annotation: The object representing the annotation that is about to be displayed. In addition to your custom annotations, this object could be an `MKUserLocation`` object representing the user’s current location.
  /// - Returns: The annotation view to display for the specified annotation or `nil` if you want to display a standard annotation view.
  public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard !annotation.isKind(of: MKUserLocation.self) else { return nil }
    guard let markerAnnotationView = mapView.dequeueReusableAnnotationView(
      withIdentifier: "Annotation",
      for: annotation) as? MKMarkerAnnotationView
    else { return nil }
    
    markerAnnotationView.canShowCallout = false
    
    markerAnnotationView.markerTintColor = OSCAPublicTransportUI.configuration.colorConfig.primaryColor
    markerAnnotationView.displayPriority = .required
    
    return markerAnnotationView
  }
}
