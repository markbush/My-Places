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
        let numItems = selectedList.pois.count
        let itemDescription = numItems == 0 ? "Empty" : (numItems == 1 ? "\(numItems) item" : "\(numItems) items")
        Group {
          if viewMode == .list {
            List(selection: $selectedPOI) {
              Section(header: Text("\(itemDescription)")) {
                ForEach(selectedList.pois.sorted(by: { $0.name < $1.name })) { poi in
                  NavigationLink(value: poi) {
                    HStack {
                      Text(poi.type?.label ?? "📍")
                      Text(poi.name)
                    }
                  }
                }
                .onDelete(perform: deletePOIs)
              }
            }
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
  
  private func deletePOIs(offsets: IndexSet) {
    guard let selectedList = selectedList else { return }
    withAnimation {
      let sortedPois = selectedList.pois.sorted(by: { $0.name < $1.name })
      for index in offsets {
        modelContext.delete(sortedPois[index])
      }
    }
  }
}

#Preview {
  ContentView()
    .modelContainer(for: [PointOfInterest.self, PlaceList.self, PlaceType.self], inMemory: true)
}

