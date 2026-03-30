//
//  PlaceTypeListView.swift
//  My Places
//
//  Created by Mark Bush on 27/03/2026.
//

import SwiftUI
import SwiftData

struct PlaceTypeListView: View {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \PlaceType.name) private var placeTypes: [PlaceType]
  
  @State private var showingAddType = false
  @State private var editingType: PlaceType?
  
  @State private var typeName = ""
  @State private var typeLabel = "📍"
  @State private var showingDuplicateNameAlert = false
  
  var body: some View {
    List {
      ForEach(placeTypes) { type in
        HStack {
          Text(type.label)
          Text(type.name)
          if type.name == PlaceType.defaultTypeName {
            Spacer()
            Text("Default")
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }
        .swipeActions {
          if type.name != PlaceType.defaultTypeName {
            Button(role: .destructive) {
              deleteType(type)
            } label: {
              Label("Delete", systemImage: "trash")
            }
            
            Button {
              editingType = type
              typeName = type.name
              typeLabel = type.label
              showingAddType = true
            } label: {
              Label("Edit", systemImage: "pencil")
            }
            .tint(.orange)
          }
        }
      }
    }
    .navigationTitle("Place Types")
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: {
          editingType = nil
          typeName = ""
          typeLabel = "📍"
          showingAddType = true
        }) {
          Label("Add Type", systemImage: "plus")
        }
      }
    }
    .sheet(isPresented: $showingAddType) {
      NavigationStack {
        Form {
          TextField("Name", text: $typeName)
          SymbolTextField(placeholder: "Symbol", text: $typeLabel)
            .frame(height: 44)
            .onChange(of: typeLabel) { _, newValue in
              if newValue.count > 1 {
                typeLabel = String(newValue.prefix(1))
              }
            }
        }
        .navigationTitle(editingType == nil ? "New Place Type" : "Edit Place Type")
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
              showingAddType = false
            }
          }
          ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
              saveType()
            }
            .disabled(typeName.isEmpty || !typeLabel.isSingleEmoji)
          }
        }
      }
    }
    .alert("Duplicate Name", isPresented: $showingDuplicateNameAlert) {
      Button("OK", role: .cancel) { }
    } message: {
      Text("A place type with this name already exists. Please choose a unique name.")
    }
  }
  
  private func saveType() {
    let name = typeName.trimmingCharacters(in: .whitespacesAndNewlines)
    
    // Validation: Check for unique name
    let fetchDescriptor = FetchDescriptor<PlaceType>(predicate: #Predicate { $0.name == name })
    if let existing = try? modelContext.fetch(fetchDescriptor), existing.contains(where: { $0.id != editingType?.id }) {
      showingDuplicateNameAlert = true
      return
    }
    
    if let editingType = editingType {
      editingType.name = name
      editingType.label = typeLabel
    } else {
      let newType = PlaceType(name: name, label: typeLabel)
      modelContext.insert(newType)
    }
    showingAddType = false
  }
  
  private func deleteType(_ type: PlaceType) {
    let defaultTypeName = PlaceType.defaultTypeName
    // Find the default "POI" type
    let typeDescriptor = FetchDescriptor<PlaceType>(predicate: #Predicate { $0.name == defaultTypeName })
    guard let defaultType = (try? modelContext.fetch(typeDescriptor))?.first else {
      return
    }
    
    // Move all POIs of this type to the default "POI" type
    for poi in type.pois {
      poi.type = defaultType
    }
    
    modelContext.delete(type)
  }
}

#Preview {
  NavigationStack {
    PlaceTypeListView()
      .modelContainer(for: [PlaceType.self, PointOfInterest.self], inMemory: true)
  }
}

