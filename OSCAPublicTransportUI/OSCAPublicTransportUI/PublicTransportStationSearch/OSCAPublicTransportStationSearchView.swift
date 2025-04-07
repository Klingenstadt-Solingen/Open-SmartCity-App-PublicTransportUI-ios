//
//  OSCAPublicTransportStationSearchView.swift
//  OSCAPublicTransportUI
//
//  Created by Igor Dias on 27.09.23.
//


import SwiftUI
import MapKit
import OSCAEssentials
import Combine
import OSCAPublicTransport

public struct OSCAPublicTransportStationSearchView: View {
  
  @ObservedObject var viewModel: OSCAPublicTransportStationSearchViewModel
  
  public init(viewModel: OSCAPublicTransportStationSearchViewModel) {
    self.viewModel = viewModel
  }
  
  
  @State private var searchText = ""
  @State private var displayedStations: [OSCAStop] = []
  
  public var body: some View {
    VStack {
      let titleColor = UITraitCollection.isDarkMode ? OSCAPublicTransportUI.configuration.colorConfig.textColor.asSwiftUIColor : OSCAPublicTransportUI.configuration.colorConfig.accentColor.asSwiftUIColor
      
      if let title = viewModel.title {
        Text(title)
          .lineLimit(1)
          .font(OSCAPublicTransportUI.configuration.fontConfig.titleHeavy.withSize(16).asSwiftUIFont)
          .foregroundColor(titleColor)
          .padding(.top, 12)
          .padding(.horizontal, 12)
          .frame(maxWidth: .infinity, alignment: .center)
      } else {
        Spacer().frame(height: 12)
      }
      
      SearchTextView(
        didChangeText: self.viewModel.searchStations,
        searchLabel: viewModel.searchText
      )
      .padding(.bottom, 12)
      
      
      switch(viewModel.searchState) {
      case .loading:
        Text(viewModel.loadingText)
          .lineLimit(1)
          .font(OSCAPublicTransportUI.configuration.fontConfig.titleHeavy.withSize(14).asSwiftUIFont)
          .foregroundColor(OSCAPublicTransportUI.configuration.colorConfig.textColor.asSwiftUIColor.opacity(0.7))
          .padding(.top, 12)
          .padding(.horizontal, 12)
          .frame(maxWidth: .infinity, alignment: .center)
      case .emptyResults:
        Text(viewModel.searchEmptyResultText)
          .lineLimit(1)
          .font(OSCAPublicTransportUI.configuration.fontConfig.titleHeavy.withSize(14).asSwiftUIFont)
          .foregroundColor(OSCAPublicTransportUI.configuration.colorConfig.textColor.asSwiftUIColor.opacity(0.7))
          .padding(.top, 12)
          .padding(.horizontal, 12)
          .frame(maxWidth: .infinity, alignment: .center)
      case .showResults:
        Text(viewModel.searchResultText)
          .lineLimit(1)
          .font(OSCAPublicTransportUI.configuration.fontConfig.titleHeavy.withSize(14).asSwiftUIFont)
          .foregroundColor(OSCAPublicTransportUI.configuration.colorConfig.textColor.asSwiftUIColor)
          .padding(.top, 6)
          .padding(.horizontal, 12)
          .frame(maxWidth: .infinity, alignment: .leading)
        
        StopList(
          stops: self.viewModel.searchResults,
          didSelect: self.viewModel.didSelectStation
        )
        
      case .showSuggested:
        Text(viewModel.suggestedStopsText)
          .lineLimit(1)
          .font(OSCAPublicTransportUI.configuration.fontConfig.titleHeavy.withSize(14).asSwiftUIFont)
          .foregroundColor(OSCAPublicTransportUI.configuration.colorConfig.textColor.asSwiftUIColor)
          .padding(.top, 6)
          .padding(.horizontal, 12)
          .frame(maxWidth: .infinity, alignment: .leading)
        
        StopList(
          stops: self.viewModel.nearbyStations,
          didSelect: self.viewModel.didSelectStation
        )
      }
      
      Spacer()
    }
    .padding()
    .onChange(of: searchText) { newValue in
      self.viewModel.searchStations(newValue)
    }
    .onReceive(self.viewModel.$nearbyStations) { nearbyStations in
      if self.displayedStations.count == 0 {
        self.displayedStations = nearbyStations
      }
    }
    .onReceive(self.viewModel.$searchResults) { stations in
      self.displayedStations = stations
    }
    .onTapGesture {
      UIApplication.shared.endEditing() // Dismiss keyboard on tap
    }
  }
}

private extension OSCAPublicTransportStationSearchView {
  struct StopList : View {
    let stops: [OSCAStop]
    let didSelect: (OSCAStop) -> Void
    
    public var body: some View {
      List(stops, id: \.id) { station in
        StationCellView(station: station)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background()
          .onTapGesture {
            self.didSelect(station)
          }
      }
      .listStyle(PlainListStyle())
    }
  }
}

private extension OSCAPublicTransportStationSearchView {
  struct StationCellView: View {
    let station: OSCAStop
    
    public var body: some View {
      Text(station.name ?? "--")
        .lineLimit(1)
        .font(OSCAPublicTransportUI.configuration.fontConfig.bodyLight.withSize(14).asSwiftUIFont)
        .foregroundColor(OSCAPublicTransportUI.configuration.colorConfig.textColor.asSwiftUIColor)
    }
  }
}

private extension OSCAPublicTransportStationSearchView {
  struct SearchTextView: View {
    let didChangeText: (String) -> Void
    let searchLabel: String
    
    @State private var searchText = ""
    
    public var body: some View {
      HStack {
        TextField(searchLabel, text: $searchText)
          .keyboardType(.default)
          .submitLabel(.search)
          .disableAutocorrection(true)
          .autocapitalization(.none)
          .textContentType(.location)
          .foregroundColor(OSCAPublicTransportUI.configuration.colorConfig.textColor.asSwiftUIColor)
          .font(OSCAPublicTransportUI.configuration.fontConfig.bodyLight.withSize(14).asSwiftUIFont)
          .foregroundColor(OSCAPublicTransportUI.configuration.colorConfig.textColor.asSwiftUIColor)
          .padding(.vertical, 12)
          .padding(.trailing, 40)
          .padding(.leading, 12)
          .background(
            RoundedRectangle(cornerRadius: 10)
              .fill(Color(.systemGray6))
              .overlay(
                RoundedRectangle(cornerRadius: 10)
                  .stroke(Color.white, lineWidth: UITraitCollection.isDarkMode ? 1 : 0)
              )
          )
          .overlay(
            HStack {
              Spacer()
              
              
              HStack (alignment: .center, spacing: 4) {
                Spacer()
                if !searchText.isEmpty {
                  Button(action: {
                    self.searchText = ""
                  }) {
                    Image(systemName: "xmark.circle.fill")
                      .foregroundColor(OSCAPublicTransportUI.configuration.colorConfig.grayDark.asSwiftUIColor)
                      .frame(width: 18, height: 18)
                  }.frame(width: 18, height: 18, alignment: .trailing)
                }
                
                
                Image(systemName: "magnifyingglass")
                  .renderingMode(.template)
                  .resizable()
                  .frame(width: 18, height: 18)
                  .foregroundColor(.gray)
                  .frame(alignment: .trailing)
                  .padding(.trailing)
              }
            }
              .frame(maxWidth: .infinity, alignment: .leading)
          )
          .onChange(of: searchText) { newValue in
            self.didChangeText(newValue)
          }
      }
    }
  }
  
}

extension UITraitCollection {
  public static var isDarkMode: Bool {
    return UITraitCollection.current.userInterfaceStyle == .dark
  }
}
