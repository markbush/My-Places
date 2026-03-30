//
//  AddPOIView.swift
//  My Places
//
//  Created by Mark Bush on 30/03/2026.
//

import SwiftUI
import SwiftData

struct AddPOIView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @Query(sort: \PlaceType.name) private var placeTypes: [PlaceType]
  
  let list: PlaceList
  
  @State private var name = ""
  @State private var selectedType: PlaceType?
  @State private var showingDuplicateNameAlert = false
  
  var body: some View {
    NavigationStack {
      Form {
        TextField("Name", text: $name)
        Picker("Type", selection: $selectedType) {
          ForEach(placeTypes) { type in
            HStack {
              Text("\(type.label) \(type.name)")
            }.tag(Optional(type))
          }
        }
      }
      .navigationTitle("New POI")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            addPOI()
          }
          .disabled(name.isEmpty || selectedType == nil)
        }
      }
      .alert("Duplicate Name", isPresented: $showingDuplicateNameAlert) {
        Button("OK", role: .cancel) { }
      } message: {
        Text("A point of interest with this name already exists. Please choose a unique name.")
      }
      .onAppear {
        if selectedType == nil {
          selectedType = placeTypes.first(where: { $0.name == PlaceType.defaultTypeName })
        }
      }
    }
  }
  
  private func addPOI() {
    let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
    
    // Validation: Check for unique name
    let fetchDescriptor = FetchDescriptor<PointOfInterest>(predicate: #Predicate { $0.name == trimmedName })
    if let count = try? modelContext.fetchCount(fetchDescriptor), count > 0 {
      showingDuplicateNameAlert = true
      return
    }
    
    let newPOI = PointOfInterest(name: trimmedName, type: selectedType, list: list)
    modelContext.insert(newPOI)
    dismiss()
  }
}

#Preview {
  let schema = Schema([PointOfInterest.self, PlaceList.self, PlaceType.self])
  let container = try! ModelContainer(for: schema, configurations: [ModelConfiguration(isStoredInMemoryOnly: true)])
  let list = PlaceList(name: "Test List", label: "📋")
  container.mainContext.insert(list)
  return AddPOIView(list: list)
    .modelContainer(container)
}

