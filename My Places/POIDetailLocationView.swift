//
//  POIDetailLocationView.swift
//  My Places
//
//  Created by Mark Bush on 30/03/2026.
//

import SwiftUI
import MapKit

struct POIDetailLocationView: View {
  @Bindable var poi: PointOfInterest
  @State private var showingLocationPicker = false
  
  var body: some View {
    Section("Location") {
      if let lat = poi.latitude, let lon = poi.longitude {
        LabeledContent("Latitude", value: String(format: "%.6f", lat))
        LabeledContent("Longitude", value: String(format: "%.6f", lon))
        
        Button("Change Location") {
          showingLocationPicker = true
        }
        
        Button("Clear Location", role: .destructive) {
          poi.latitude = nil
          poi.longitude = nil
        }
      } else {
        Text("No location set")
          .foregroundColor(.secondary)
        
        Button("Set Location") {
          showingLocationPicker = true
        }
      }
      
      if poi.coordinate != nil {
        Button("Navigate to") {
          navigateToPOI()
        }
      }
    }
    .sheet(isPresented: $showingLocationPicker) {
      LocationPickerView(initialCoordinate: poi.coordinate) { coordinate in
        poi.latitude = coordinate.latitude
        poi.longitude = coordinate.longitude
      }
    }
  }
  
  private func navigateToPOI() {
    guard let coordinate = poi.coordinate else { return }
    let placemark = MKPlacemark(coordinate: coordinate)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = poi.name
    mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
  }
}

