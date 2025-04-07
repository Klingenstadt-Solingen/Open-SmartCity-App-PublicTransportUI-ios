//
//  OSCAPublicTransportStationSearchViewController.swift
//  OSCAPublicTransportUI
//
//  Created by Igor Dias on 27.09.23.
//

import Foundation
import SwiftUI

public class OSCAPublicTransportStationSearchViewController: UIHostingController<OSCAPublicTransportStationSearchView> {
  
  private var viewModel: OSCAPublicTransportStationSearchViewModel!
  
  init(with viewModel: OSCAPublicTransportStationSearchViewModel) {
    self.viewModel = viewModel
    let view = OSCAPublicTransportStationSearchView(viewModel: self.viewModel)
    super.init(rootView: view)
  }
  
  @objc required dynamic init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented yet")
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.prefersLargeTitles = false
    navigationItem.title = "Bahnhof auswählen"
    
    viewModel.viewDidLoad()
  }
}
