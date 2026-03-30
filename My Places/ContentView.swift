//
//  ContentView.swift
//  My Places
//
//  Created by Mark Bush on 27/03/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \PlaceList.name) private var placeLists: [PlaceList]
  @Query(sort: \PlaceType.name) private var placeTypes: [PlaceType]
  
  @State private var selectedList: PlaceList?
  @State private var selectedPOI: PointOfInterest?
  
  @State private var showingAddPOI = false
  
  enum ViewMode: String, CaseIterable {
    case list = "List"
    case map = "Map"
  }
  @State private var viewMode: ViewMode = .list
  
  var body: some View {
    NavigationSplitView {
      List(selection: $selectedList) {
        ForEach(placeLists) { list in
          NavigationLink(value: list) {
            HStack {
              Text(list.label)
              Text(list.name)
              Spacer()
              Text(String(list.pois.count))
            }
          }
        }
      }
      .navigationTitle("My Places")
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          NavigationLink(destination: PlaceListView()) {
            Label("Lists", systemImage: "list.bullet")
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          NavigationLink(destination: PlaceTypeListView()) {
            Label("Types", systemImage: "tag")
          }
        }
      }
    } content: {
      if let selectedList = selectedList {
        Group {
          if viewMode == .list {
            POIListView(list: selectedList, selectedPOI: $selectedPOI)
          } else {
            POIMapView(list: selectedList, selectedPOI: $selectedPOI)
          }
        }
        .navigationTitle(selectedList.name)
        .toolbar {
          ToolbarItem(placement: .principal) {
            Picker("View Mode", selection: $viewMode) {
              ForEach(ViewMode.allCases, id: \.self) { mode in
                Text(mode.rawValue).tag(mode)
              }
            }
            .pickerStyle(.segmented)
            .frame(width: 150)
          }
          ToolbarItem(placement: .navigationBarTrailing) {
            EditButton()
          }
          ToolbarItem {
            Button(action: {
              showingAddPOI = true
            }) {
              Label("Add POI", systemImage: "plus")
            }
          }
        }
      } else {
        Text("Select a list")
      }
    } detail: {
      if let selectedPOI = selectedPOI {
        POIDetailView(poi: selectedPOI)
      } else {
        Text("Select a point of interest")
      }
    }
    .sheet(isPresented: $showingAddPOI) {
      if let selectedList = selectedList {
        AddPOIView(list: selectedList)
      }
    }
    .onAppear {
      ensureDefaults()
      if selectedList == nil {
        selectedList = placeLists.first(where: { $0.name == PlaceList.defaultListName })
      }
    }
  }
  
  private func ensureDefaults() {
    PlaceList.ensureDefaults(modelContext: modelContext)
  }
}

#Preview {
  ContentView()
    .modelContainer(for: [PointOfInterest.self, PlaceList.self, PlaceType.self], inMemory: true)
}

