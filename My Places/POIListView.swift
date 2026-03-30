//
//  POIListView.swift
//  My Places
//
//  Created by Mark Bush on 30/03/2026.
//

import SwiftUI
import SwiftData

struct POIListView: View {
  @Environment(\.modelContext) private var modelContext
  let list: PlaceList
  @Binding var selectedPOI: PointOfInterest?
  
  private var sortedPOIs: [PointOfInterest] {
    list.pois.sorted(by: { $0.name < $1.name })
  }
  
  private var itemDescription: String {
    let count = list.pois.count
    return count == 0 ? "Empty" : (count == 1 ? "1 item" : "\(count) items")
  }
  
  var body: some View {
    List(selection: $selectedPOI) {
      Section(header: Text(itemDescription)) {
        ForEach(sortedPOIs) { poi in
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
  }
  
  private func deletePOIs(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        modelContext.delete(sortedPOIs[index])
      }
    }
  }
}

#Preview {
  let schema = Schema([PointOfInterest.self, PlaceList.self, PlaceType.self])
  let container = try! ModelContainer(for: schema, configurations: [ModelConfiguration(isStoredInMemoryOnly: true)])
  let list = PlaceList(name: "Test List", label: "📋")
  container.mainContext.insert(list)
  return POIListView(list: list, selectedPOI: .constant(nil))
    .modelContainer(container)
}

