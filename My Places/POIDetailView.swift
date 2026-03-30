//
//  POIDetailView.swift
//  My Places
//
//  Created by Mark Bush on 28/03/2026.
//

import SwiftUI
import SwiftData
import MapKit
import PhotosUI

struct POIDetailView: View {
  @Environment(\.modelContext) private var modelContext
  @Bindable var poi: PointOfInterest
  
  @Query(sort: \PlaceType.name) private var placeTypes: [PlaceType]
  @Query(sort: \PlaceList.name) private var placeLists: [PlaceList]
  
  @State private var showingLocationPicker = false
  @State private var selectedItem: PhotosPickerItem?
  @State private var showingDuplicateNameAlert = false
  @State private var pendingName: String = ""
  
  var body: some View {
    Form {
      Section {
        if let imageData = poi.imageData, let uiImage = UIImage(data: imageData) {
          Image(uiImage: uiImage)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .listRowInsets(EdgeInsets())
        }
        
        PhotosPicker(selection: $selectedItem, matching: .images) {
          Label(poi.imageData == nil ? "Add Image" : "Change Image", systemImage: "photo")
        }
        
        if poi.imageData != nil {
          Button("Remove Image", role: .destructive) {
            poi.imageData = nil
            selectedItem = nil
          }
        }
      } header: {
        Text("Image")
      }
      
      Section("Basic Info") {
        TextField("Name", text: $pendingName, onEditingChanged: { isEditing in
          if !isEditing {
            validateAndSaveName()
          }
        })
        
        Picker("Type", selection: $poi.type) {
          ForEach(placeTypes) { type in
            HStack {
              Text("\(type.label) \(type.name)")
            }.tag(Optional(type))
          }
        }
        
        Picker("List", selection: $poi.list) {
          ForEach(placeLists) { list in
            HStack {
              Text("\(list.label) \(list.name)")
            }.tag(list)
          }
        }
      }
      
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
    .onChange(of: selectedItem) { _, newItem in
      Task {
        if let data = try? await newItem?.loadTransferable(type: Data.self) {
          poi.imageData = data
        }
      }
    }
    .onAppear {
      pendingName = poi.name
    }
    .alert("Duplicate Name", isPresented: $showingDuplicateNameAlert) {
      Button("OK", role: .cancel) {
        pendingName = poi.name
      }
    } message: {
      Text("A point of interest with this name already exists. Reverting change.")
    }
  }
  
  private func validateAndSaveName() {
    let newName = pendingName.trimmingCharacters(in: .whitespacesAndNewlines)
    if newName == poi.name { return }
    if newName.isEmpty {
      pendingName = poi.name
      return
    }
    
    let fetchDescriptor = FetchDescriptor<PointOfInterest>(predicate: #Predicate { $0.name == newName })
    if let count = try? modelContext.fetchCount(fetchDescriptor), count > 0 {
      showingDuplicateNameAlert = true
    } else {
      poi.name = newName
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

