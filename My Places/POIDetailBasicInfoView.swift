//
//  POIDetailBasicInfoView.swift
//  My Places
//
//  Created by Mark Bush on 30/03/2026.
//

import SwiftUI
import SwiftData

struct POIDetailBasicInfoView: View {
  @Environment(\.modelContext) private var modelContext
  @Bindable var poi: PointOfInterest
  
  @Query(sort: \PlaceType.name) private var placeTypes: [PlaceType]
  @Query(sort: \PlaceList.name) private var placeLists: [PlaceList]
  
  @State private var showingDuplicateNameAlert = false
  @State private var pendingName: String = ""
  
  var body: some View {
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
}

