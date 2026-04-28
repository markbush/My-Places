//
//  POIMapView.swift
//  My Places
//
//  Created by Mark Bush on 28/03/2026.
//

import SwiftUI
import MapKit
import SwiftData

struct POIMapView: View {
  @Environment(\.modelContext) private var modelContext
  var list: PlaceList
  @Binding var selectedPOI: PointOfInterest?
  
  @Query(sort: \PlaceType.name) private var placeTypes: [PlaceType]
  
  @State private var position: MapCameraPosition = .automatic
  @State private var showingAddPOI = false
  @State private var newPOICoordinate: CLLocationCoordinate2D?
  @State private var newPOIName = ""
  @State private var selectedType: PlaceType?
  @State private var showingDuplicateNameAlert = false
  
  var locatedPOIs: [PointOfInterest] {
    list.pois.filter { $0.latitude != nil && $0.longitude != nil }
  }
  
  var body: some View {
    MapReader { proxy in
      Map(position: $position, selection: $selectedPOI) {
        ForEach(locatedPOIs) { poi in
          if let coordinate = poi.coordinate {
            Annotation(poi.name, coordinate: coordinate) {
              VStack(spacing: 0) {
                if selectedPOI == poi {
                  POICalloutView(poi: poi)
                    .transition(.scale.combined(with: .opacity))
                }
                
                Text(poi.type?.label ?? "📍")
                  .font(.title)
                  .padding(5)
                  .background(.white)
                  .clipShape(Circle())
                  .shadow(radius: 3)
              }
            }
            .tag(poi)
          }
        }
        UserAnnotation()
      }
      .mapStyle(.standard)
      .mapControls {
        MapUserLocationButton()
        MapCompass()
        MapScaleView()
      }
      .onAppear {
        if !locatedPOIs.isEmpty && selectedPOI == nil {
          position = .automatic
        } else if locatedPOIs.isEmpty {
          position = .userLocation(fallback: .automatic)
        }
      }
      .gesture(
        LongPressGesture(minimumDuration: 0.5)
          .sequenced(before: DragGesture(minimumDistance: 0))
          .onEnded { value in
            switch value {
              case .second(true, let drag):
                if let location = drag?.location,
                   let coordinate = proxy.convert(location, from: .local) {
                  handleLongPress(at: coordinate)
                }
              default:
                break
            }
          }
      )
    }
    .sheet(isPresented: $showingAddPOI) {
      NavigationStack {
        Form {
          TextField("Name", text: $newPOIName)
          Picker("Type", selection: $selectedType) {
            ForEach(placeTypes) { type in
              HStack {
                Text("\(type.label) \(type.name)")
              }.tag(Optional(type))
            }
          }
          if let coord = newPOICoordinate {
            Section("Location") {
              Text("\(coord.latitude, specifier: "%.6f"), \(coord.longitude, specifier: "%.6f")")
            }
          }
        }
        .navigationTitle("New POI from Map")
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
              showingAddPOI = false
            }
          }
          ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
              addPOI()
            }
            .disabled(newPOIName.isEmpty || selectedType == nil)
          }
        }
      }
      .alert("Duplicate Name", isPresented: $showingDuplicateNameAlert) {
        Button("OK", role: .cancel) { }
      } message: {
        Text("A point of interest with this name already exists. Please choose a unique name.")
      }
    }
  }
  
  private func handleLongPress(at coordinate: CLLocationCoordinate2D) {
    newPOICoordinate = coordinate
    newPOIName = ""
    selectedType = placeTypes.first(where: { $0.name == PlaceType.defaultTypeName })
    showingAddPOI = true
  }
  
  private func addPOI() {
    let name = newPOIName.trimmingCharacters(in: .whitespacesAndNewlines)
    
    let fetchDescriptor = FetchDescriptor<PointOfInterest>(predicate: #Predicate { $0.name == name })
    if let count = try? modelContext.fetchCount(fetchDescriptor), count > 0 {
      showingDuplicateNameAlert = true
      return
    }
    
    let newPOI = PointOfInterest(name: name, type: selectedType, list: list)
    newPOI.latitude = newPOICoordinate?.latitude
    newPOI.longitude = newPOICoordinate?.longitude
    modelContext.insert(newPOI)
    showingAddPOI = false
    selectedPOI = newPOI
  }
}

struct POICalloutView: View {
  let poi: PointOfInterest
  
  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      if let imageData = poi.imageData, let uiImage = UIImage(data: imageData) {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFill()
          .frame(width: 80, height: 60)
          .cornerRadius(8)
          .clipped()
      }
      
      HStack {
        Text(poi.name)
          .font(.caption)
          .bold()
          .lineLimit(1)
        
        Spacer()
        
        Button(action: navigateToPOI) {
          Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
            .font(.title2)
            .foregroundStyle(.blue)
        }
      }
    }
    .padding(8)
    .background(.white)
    .cornerRadius(12)
    .shadow(radius: 5)
    .frame(width: 120)
    .offset(y: -50) // Position above the marker
  }
  
  private func navigateToPOI() {
    guard let coordinate = poi.coordinate else { return }
    let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    let mapItem = MKMapItem(location: location, address: nil)
    mapItem.name = poi.name
    mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
  }
}

#Preview {
  let schema = Schema([PointOfInterest.self, PlaceList.self, PlaceType.self])
  let container = try! ModelContainer(for: schema, configurations: [ModelConfiguration(isStoredInMemoryOnly: true)])
  let list = PlaceList(name: "Preview List", label: "📋")
  container.mainContext.insert(list)
  return POIMapView(list: list, selectedPOI: .constant(nil))
    .modelContainer(container)
}


