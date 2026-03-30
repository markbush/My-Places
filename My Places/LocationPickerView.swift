//
//  LocationPickerView.swift
//  My Places
//
//  Created by Mark Bush on 28/03/2026.
//

import SwiftUI
import MapKit

struct LocationPickerView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var position: MapCameraPosition
  @State private var selectedCoordinate: CLLocationCoordinate2D
  
  var onSave: (CLLocationCoordinate2D) -> Void
  
  init(initialCoordinate: CLLocationCoordinate2D?, onSave: @escaping (CLLocationCoordinate2D) -> Void) {
    let coordinate = initialCoordinate ?? CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278) // Default to London
    _selectedCoordinate = State(initialValue: coordinate)
    _position = State(initialValue: .region(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))))
    self.onSave = onSave
  }
  
  var body: some View {
    NavigationStack {
      ZStack {
        MapReader { proxy in
          Map(position: $position) {
            Marker("Selected Location", coordinate: selectedCoordinate)
          }
          .onTapGesture { screenPoint in
            if let coordinate = proxy.convert(screenPoint, from: .local) {
              selectedCoordinate = coordinate
            }
          }
        }
        
        VStack {
          Spacer()
          Text("Tap the map to select a location")
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(10)
            .padding(.bottom, 20)
        }
      }
      .navigationTitle("Select Location")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            onSave(selectedCoordinate)
            dismiss()
          }
        }
      }
    }
  }
}

#Preview {
  LocationPickerView(initialCoordinate: nil) { _ in }
}

