//
//  POIDetailView.swift
//  My Places
//
//  Created by Mark Bush on 28/03/2026.
//

import SwiftUI
import SwiftData
import MapKit

struct POIDetailView: View {
  @Environment(\.modelContext) private var modelContext
  @Bindable var poi: PointOfInterest
  
  @State private var showingLocationPicker = false
  
  var body: some View {
    Form {
      POIDetailImageView(poi: poi)
      POIDetailBasicInfoView(poi: poi)
      
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
      
      Section("Notes") {
        TextField("Note", text: Binding(
          get: { poi.note ?? "" },
          set: { poi.note = $0.isEmpty ? nil : $0 }
        ), axis: .vertical)
        .lineLimit(5...10)
      }
      
      Section("Visit History") {
        DatePicker("Last Visited", selection: Binding(
          get: { poi.lastVisited ?? .now },
          set: { poi.lastVisited = $0 }
        ), displayedComponents: .date)
        
        if poi.lastVisited != nil {
          Button("Clear Visit Date", role: .destructive) {
            poi.lastVisited = nil
          }
        } else {
          Button("Mark as Visited") {
            poi.lastVisited = .now
          }
        }
      }
    }
    .navigationTitle(poi.name)
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

//#Preview {
//    POIDetailView()
//}

